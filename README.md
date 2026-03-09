# macOS Setup

> One script to rule them all, one script to find them, one script to bring them all, and in the terminal bind them.

Everything I need to go from a fresh macOS install to a fully configured, keyboard-driven development machine. No mice were harmed in the making of this repo.

## Quick start

```bash
git clone git@github.com:pdelfino/macos-setup.git ~/projects/macos-setup
cd ~/projects/macos-setup
./bootstrap.sh
```

The bootstrap script will:
1. Install Homebrew (if missing)
2. Install all packages, casks, and fonts from the `Brewfile`
3. Clone all config repos into `~/projects/`
4. Symlink everything into place
5. Apply app preferences (Homerow, Maccy)

## What's in here

### Brewfile

All Homebrew packages, casks, and fonts — from `bat` to `zoom`. Run `brew bundle` to install everything.

### Config files

| File/Dir | What it configures |
|----------|-------------------|
| `.p10k.zsh` | Powerlevel10k zsh prompt theme |
| `.zprofile` | Shell profile (Homebrew path) |
| `.mcp.json` | Claude Code MCP server definitions |
| `config/clojure/` | Clojure deps.edn and tool configs |
| `config/gh/` | GitHub CLI (SSH protocol, aliases) |
| `config/git/ignore` | Global gitignore |

### Scripts

| Script | What it does |
|--------|-------------|
| `clj-paren-repair-claude-hook` | Babashka hook for Clojure paren repair |
| `focus-automated-chrome.sh` | Focus Selenium-controlled Chrome instances |

## The keyboard-driven ecosystem

This repo is the glue. The real configs live in their own repos:

| Repo | What | Key feature |
|------|------|-------------|
| [emacs-config](https://github.com/pdelfino/emacs-config) | Emacs setup | Ivy, Projectile, Paredit, Claude Code integration |
| [my-karabiner-elements-config](https://github.com/pdelfino/my-karabiner-elements-config) | Karabiner Elements | Emacs keybindings system-wide on macOS |
| [homerow-config](https://github.com/pdelfino/homerow-config) | Homerow + Maccy | Click anything without a mouse, M-y clipboard history |
| [iTerm2-config](https://github.com/pdelfino/iTerm2-config) | iTerm2 | Terminal preferences and profiles |
| [zshrc](https://github.com/pdelfino/zshrc) | Zsh config | Shell aliases, plugins, environment |
| [claude-config](https://github.com/pdelfino/claude-config) | Claude Code | AI assistant configuration |

## Philosophy

- **Keyboard over mouse** — Emacs keybindings everywhere via Karabiner, Homerow for clicking, Maccy for clipboard
- **Reproducible** — One `bootstrap.sh` from zero to productive
- **Modular** — Each tool has its own repo; this repo ties them together
- **Plain text** — Everything is a script, a JSON, or a YAML. No binary blobs.

## License

MIT
