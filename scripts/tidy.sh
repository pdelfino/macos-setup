#!/usr/bin/env bash
# tidy.sh - weekly housekeeping so the Mac does not drift back to
# 20 GB free and a 500-item Downloads folder (life-ops#375).
#
# What it does, in order:
#   1. Trash: delete items that have sat there 30+ days.
#   2. Caches: npm, uv, pip, Homebrew (each skipped if the tool is missing
#      or, for uv, if another uv process holds the cache lock).
#   3. ~/scratch: delete top-level entries untouched for 90+ days.
#      ~/scratch/screenshots is pruned per file with the same rule.
#   4. Downloads: REPORT (never delete) items older than 30 days, so the
#      next Claude session or Pedro can file or drop them.
#   5. Print free space before and after.
#
# Usage:
#   scripts/tidy.sh            # do it
#   scripts/tidy.sh --dry-run  # print what would happen, touch nothing
#
# Runs weekly from launchd (com.pedro.tidy, Sunday 09:00), log at
# ~/scratch/tidy.log. Safe to run by hand any time.
set -uo pipefail

# launchd starts with a bare PATH; make the tools findable.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
if [ -d "$HOME/.nvm/versions/node" ]; then
    latest_node="$(ls -d "$HOME"/.nvm/versions/node/*/bin 2>/dev/null | sort -V | tail -1)"
    [ -n "$latest_node" ] && export PATH="$latest_node:$PATH"
fi

DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

TRASH_DAYS=30
SCRATCH_DAYS=90
DOWNLOADS_DAYS=30

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }
run() { if [ "$DRY" = 1 ]; then log "DRY: $*"; else "$@" >/dev/null 2>&1; fi; }
free_gb() { df -g / | awk 'NR==2 {print $4}'; }

log "=== tidy start (dry-run=$DRY)"
before="$(free_gb)"

# 1. Trash, 30+ days old. macOS keeps no per-item deletion date we can
#    read cheaply, so mtime of the item itself is the proxy.
log "--- Trash: items older than $TRASH_DAYS days"
find "$HOME/.Trash" -mindepth 1 -maxdepth 1 -mtime +"$TRASH_DAYS" -print 2>/dev/null | while IFS= read -r f; do
    log "trash: $(basename "$f")"
    run /bin/rm -rf "$f"
done

# 2. Caches.
log "--- caches"
if command -v npm >/dev/null; then run npm cache clean --force && log "npm cache cleaned"; fi
if command -v uv >/dev/null; then
    if lsof "$HOME/.cache/uv/.lock" >/dev/null 2>&1; then
        log "uv cache SKIPPED: lock held by a running uv process"
    else
        run uv cache clean && log "uv cache cleaned"
    fi
fi
if command -v pip3 >/dev/null; then run pip3 cache purge && log "pip cache purged"; fi
if command -v brew >/dev/null; then run brew cleanup --prune=all && log "brew cleanup done"; fi

# 3. ~/scratch, 90+ days untouched. Top-level entries only, so a project
#    folder is judged by its own mtime, not by files deep inside it.
log "--- ~/scratch: entries untouched $SCRATCH_DAYS+ days"
if [ -d "$HOME/scratch" ]; then
    find "$HOME/scratch" -mindepth 1 -maxdepth 1 ! -name screenshots ! -name 'tidy*.log' -mtime +"$SCRATCH_DAYS" -print 2>/dev/null | while IFS= read -r f; do
        log "scratch: $(basename "$f")"
        run /bin/rm -rf "$f"
    done
    find "$HOME/scratch/screenshots" -type f -mtime +"$SCRATCH_DAYS" -print 2>/dev/null | while IFS= read -r f; do
        log "screenshot: ${f#$HOME/scratch/screenshots/}"
        run /bin/rm -f "$f"
    done
    find "$HOME/scratch/screenshots" -mindepth 1 -type d -empty -delete 2>/dev/null
fi

# 4. Downloads: report only.
log "--- Downloads: items older than $DOWNLOADS_DAYS days (report only, nothing deleted)"
old_count=0
while IFS= read -r f; do
    old_count=$((old_count + 1))
    size="$(du -sk "$f" 2>/dev/null | cut -f1)"
    log "downloads: $(printf '%6d' "${size:-0}") KB  $(basename "$f")"
done < <(find "$HOME/Downloads" -mindepth 1 -maxdepth 1 -mtime +"$DOWNLOADS_DAYS" -print 2>/dev/null | sort)
log "Downloads has $old_count item(s) older than $DOWNLOADS_DAYS days; file them (file-receipt skill) or delete"

after="$(free_gb)"
log "=== tidy done, free ${before} GB -> ${after} GB"
