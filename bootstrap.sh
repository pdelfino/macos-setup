#!/bin/bash
# Bootstrap a fresh macOS machine with all configs and tools.
# Run this after a clean macOS install.

set -euo pipefail

PROJECTS_DIR="$HOME/projects"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Installing Homebrew ==="
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed, skipping."
fi

echo "=== Installing packages from Brewfile ==="
brew bundle --file="$SCRIPT_DIR/Brewfile"

echo "=== Cloning config repos ==="
mkdir -p "$PROJECTS_DIR"

repos=(
    "emacs-config"
    "karabiner-config"
    "iterm2-config"
    "claude-config"
    "zshrc"
    "homerow-config"
)

for repo in "${repos[@]}"; do
    if [ ! -d "$PROJECTS_DIR/$repo" ]; then
        git clone "git@github.com:pdelfino/$repo.git" "$PROJECTS_DIR/$repo"
    else
        echo "$repo already cloned, skipping."
    fi
done

echo "=== Symlinking config files ==="

# Emacs
mkdir -p ~/.emacs.d
ln -sf "$PROJECTS_DIR/emacs-config/init.el" ~/.emacs.d/init.el

# Karabiner
ln -sf "$PROJECTS_DIR/karabiner-config" ~/.config/karabiner

# Zsh
ln -sf "$PROJECTS_DIR/zshrc/.zshrc" ~/.zshrc

# Homerow
mkdir -p ~/.config
ln -sf "$PROJECTS_DIR/homerow-config" ~/.config/homerow

# Powerlevel10k
ln -sf "$SCRIPT_DIR/.p10k.zsh" ~/.p10k.zsh

# Shell profile
ln -sf "$SCRIPT_DIR/.zprofile" ~/.zprofile

# Git
mkdir -p ~/.config/git
ln -sf "$SCRIPT_DIR/config/git/ignore" ~/.config/git/ignore

# GitHub CLI
mkdir -p ~/.config/gh
ln -sf "$SCRIPT_DIR/config/gh/config.yml" ~/.config/gh/config.yml

# Clojure
mkdir -p ~/.config/clojure/tools
ln -sf "$SCRIPT_DIR/config/clojure/deps.edn" ~/.config/clojure/deps.edn
for f in "$SCRIPT_DIR"/config/clojure/*.edn; do
    basename="$(basename "$f")"
    [ "$basename" = "deps.edn" ] && continue
    ln -sf "$f" ~/.config/clojure/tools/"$basename"
done

# MCP servers
ln -sf "$SCRIPT_DIR/.mcp.json" ~/.mcp.json

# Custom scripts
mkdir -p ~/.local/bin
for f in "$SCRIPT_DIR"/scripts/*; do
    ln -sf "$f" ~/.local/bin/"$(basename "$f")"
done

echo "=== Applying app preferences ==="

# Homerow + Maccy
"$PROJECTS_DIR/homerow-config/setup.sh"

echo ""
echo "=== Done! ==="
echo "Remaining manual steps:"
echo "  1. Open iTerm2 and import profile from iterm2-config repo"
echo "  2. Log into Brave, Chrome, Slack, Signal"
echo "  3. Install Homerow from https://www.homerow.app/"
echo "  4. Restart apps for preferences to take effect"
