# macos-setup

![Apollo in the Forge of Vulcan](https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Vel%C3%A1zquez_-_La_Fragua_de_Vulcano_%28Museo_del_Prado%2C_1630%29.jpg/960px-Vel%C3%A1zquez_-_La_Fragua_de_Vulcano_%28Museo_del_Prado%2C_1630%29.jpg)

*"Apollo in the Forge of Vulcan" (1630) by Diego Velázquez — [Wikipedia](https://en.wikipedia.org/wiki/Apollo_in_the_Forge_of_Vulcan)*

**From zero to keyboard-driven dev machine in one script. No mice required.**

> One script to rule them all, one script to find them, one script to bring them all, and in the terminal bind them.

## About

Everything needed to go from a fresh macOS install to a fully configured, keyboard-driven development machine. The bootstrap script installs packages, clones config repos, symlinks dotfiles, and applies app preferences -- all without touching a mouse.

This repo is the orchestration layer for a modular dotfiles ecosystem. Each tool has its own repository; this one ties them together.

## Quick Start

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

## What's Inside

### Brewfile

All Homebrew packages, casks, and fonts. Includes Emacs (Mac port), Clojure tooling (Leiningen, Babashka, clj-kondo), Node.js (via nvm), Karabiner Elements, iTerm2, and more. Run `brew bundle` to install everything.

### Config Files

| File/Dir | What it configures |
|----------|-------------------|
| `.p10k.zsh` | Powerlevel10k ZSH prompt theme |
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

## The Keyboard-Driven Ecosystem

This repo is the glue. The real configs live in their own repos:

| Repo | What | Key feature |
|------|------|-------------|
| [emacs-config](https://github.com/pdelfino/emacs-config) | Emacs setup | Ivy, Projectile, Paredit, Claude Code integration |
| [karabiner-config](https://github.com/pdelfino/karabiner-config) | Karabiner Elements | Emacs keybindings system-wide on macOS |
| [homerow-config](https://github.com/pdelfino/homerow-config) | Homerow + Maccy | Click anything without a mouse, M-y clipboard history |
| [iterm2-config](https://github.com/pdelfino/iterm2-config) | iTerm2 | Terminal preferences and profiles |
| [zshrc](https://github.com/pdelfino/zshrc) | ZSH config | Shell aliases, plugins, environment |
| [claude-config](https://github.com/pdelfino/claude-config) | Claude Code | AI assistant configuration |

## Philosophy

- **Keyboard over mouse** -- Emacs keybindings everywhere via Karabiner, Homerow for clicking, Maccy for clipboard
- **Reproducible** -- One `bootstrap.sh` from zero to productive
- **Modular** -- Each tool has its own repo; this repo ties them together
- **Plain text** -- Everything is a script, a JSON, or a dotfile. No binary blobs.

## Requirements

- macOS (Apple Silicon supported)
- Internet connection (for Homebrew and Git clones)

## Remaining Manual Steps

After running the bootstrap, a few things still need manual setup:

1. Open iTerm2 and import the profile from the iterm2-config repo
2. Log into Brave, Chrome, Slack, Signal
3. Install [Homerow](https://www.homerow.app/)
4. Restart apps for preferences to take effect

## License

MIT
