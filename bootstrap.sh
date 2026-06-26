#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
NIX_DIR="$DOTFILES_DIR/nix"
LOCAL_CONFIG="$NIX_DIR/common.local.nix"

USERNAME="$(id -un)"
USERHOME="$HOME"

if [ ! -d "$NIX_DIR" ]; then
    echo "Expected nix directory at: $NIX_DIR"
    exit 1
fi

if [ ! -f "$LOCAL_CONFIG" ]; then
    echo ""
    echo "============================================================"
    echo "This script installs Nix packages, symlinks dotfiles,"
    echo "and configures your development environment."
    echo "Review this repository before running on any machine."
    echo "============================================================"
    echo ""
    echo "=== Detected user configuration ==="
    echo "  Username: $USERNAME"
    echo "  Home:     $USERHOME"
    echo ""
    read -r -p "Continue? [Y/n] " response
    case "$response" in
    n | N)
        echo "Aborted. Update nix/common.local.nix manually and run again."
        exit 1
        ;;
    esac

    cat >"$LOCAL_CONFIG" <<EOF
{ ... }:
{
  users.users.user = {
    name = "$USERNAME";
    home = "$USERHOME";
  };
}
EOF
    echo "Created nix/common.local.nix"
fi

echo ""
echo "Building and switching nix-darwin system generation..."
sudo nix run "$NIX_DIR#darwin-rebuild" -- switch --flake "$NIX_DIR#system"
