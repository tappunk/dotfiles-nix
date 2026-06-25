![dotfiles-nix](https://raw.githubusercontent.com/tappunk/.github/refs/heads/main/assets/dotfiles-nix.webp)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![X Follow](https://img.shields.io/twitter/follow/tappunk?style=social)](https://x.com/tappunk)

# dotfiles-nix

**Hardened macOS dotfiles via Nix for a zero-trust AI workstation.** Declarative config, reproducible builds, muthr integration.

[What's installed](#whats-installed) • [Quick start](#quick-start) • [Architecture](#architecture) • [Updating](#updating)

## What's installed

- **Ghostty** — terminal emulator
- **Neovim** — editor
- **Zsh** — shell with Starship prompt
- **Git** — with global ignore rules
- **Eza** — modern ls replacement
- **Fastfetch** — system info display
- **muthr** — zero-trust AI orchestrator (installed during nix-darwin activation)

### Configuration files

| Config       | Source                   | Installed at                           |
| ------------ | ------------------------ | -------------------------------------- |
| `ghostty/`   | `ghostty/`               | `~/.config/ghostty/config`             |
| `nvim/`      | `nvim/`                  | `~/.config/nvim/`                      |
| `zsh/`       | `zsh/`                   | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` |
| `git/`       | `git/`                   | `~/.gitconfig`, `~/.gitignore_global`  |
| `starship/`  | `starship/starship.toml` | `~/.config/starship.toml`              |
| `eza/`       | `eza/theme.yml`          | `~/.config/eza/theme.yml`              |
| `fastfetch/` | `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc`     |

All files are managed declaratively via nix-darwin flakes with SHA256-pinned hashes. muthr stores runtime state (PIDs, logs, generated JSON) in `~/.cache/muthr/`.

## Quick start

```bash
git clone https://github.com/tappunk/dotfiles-nix ~/dotfiles-nix
cd ~/dotfiles-nix
./bootstrap.sh
exec zsh
```

Requires Determinate Nix — install from [determinate.systems](https://determinate.systems).

> [!WARNING]
> Requires familiarity with declarative Nix systems, `nix-darwin`, and reviewing code before execution.

## Architecture

- **Inference** — `llama-server` on the host with configurable presets and auto VRAM management
- **Agent isolation** — Debian 13 VMs via Lima (`vmType: vz`) that sandbox agents; VMs stay running until stopped with `muthr down`
- **MCP services** — Dedicated Lima VM for potentially dangerous MCPs, isolated from the host
- **System management** — `nix-darwin` flakes with SHA256-pinned hashes, Ghostty + Neovim + Starship

## Updating

```bash
cd ~/dotfiles-nix
git pull
./bootstrap.sh
```
