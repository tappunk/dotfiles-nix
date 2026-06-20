![Hardened Local AI Workstation](https://raw.githubusercontent.com/tappunk/.github/refs/heads/main/assets/dotfiles-banner.webp)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![X Follow](https://img.shields.io/twitter/follow/tappunk?style=social)](https://x.com/tappunk)

# dotfiles-nix

**Hardened macOS dotfiles for a zero-trust local AI workstation. A real-world reference implementation for [muthr](https://github.com/tappunk/muthr) that shows secure AI orchestration on Apple Silicon with reproducible Nix-built dependencies.**

> [!WARNING]
> Requires familiarity with declarative Nix systems, `nix-darwin`, and reviewing code before execution.

## Architecture

- **Inference** — `llama-server` on the host with configurable presets and auto VRAM management
- **Agent isolation** — Debian 13 VMs via Lima (`vmType: vz`) that sandbox agents and auto-stop when done
- **MCP services** — Dedicated Lima VM for potentially dangerous MCPs, isolated from the host
- **System management** — `nix-darwin` flakes with SHA256-pinned hashes, Ghostty + Neovim + Starship

## Prerequisites

macOS (Apple Silicon), [Determinate Nix](https://determinate.systems), ≥48 GB RAM for 35B models.

> [!NOTE]
> The ≥48GB RAM requirement applies to 35B models. Smaller models run on machines with less memory.

## Usage

```bash
# 0. Install Ghostty (recommended)
# [https://ghostty.org/download](https://ghostty.org/download)

# 1. Xcode Command Line Tools
xcode-select --install

# 2. Determinate Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 3. Bootstrap
git clone https://github.com/tappunk/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
exec zsh

# muthr init runs automatically during nix activation to install configs

# Rebuild anytime
muthr rebase
```

## Configuration

Activation symlinks dotfiles from `~/dotfiles-nix/` to `~/.config/`:

- `ghostty/` → `~/.config/ghostty/config`
- `nvim/` → `~/.config/nvim`
- `zsh/` → `~/.zshrc`, `~/.zshenv`, `~/.zprofile`
- `git/` → `~/.gitconfig`, `~/.gitignore_global`
- `starship/starship.toml` → `~/.config/starship.toml`
- `eza/theme.yml` → `~/.config/eza/theme.yml`
- `fastfetch/config.jsonc` → `~/.config/fastfetch/config.jsonc`

`muthr` stores runtime state (PIDs, logs, generated JSON) in `~/.cache/muthr/`.

## Installation

Declarative via nix-darwin flakes:

```bash
git clone https://github.com/tappunk/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

Run `muthr rebase` for subsequent updates.
