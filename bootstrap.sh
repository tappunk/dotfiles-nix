#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles-nix"
LOCAL_CONFIG="$DOTFILES_DIR/nix/common.local.nix"

USERNAME=$(id -un)
USERHOME="$HOME"

if [ ! -f "$LOCAL_CONFIG" ]; then
    echo ""
    echo "============================================================"
    echo "This script installs Nix packages, symlinks dotfiles,"
    echo "and configures your entire development environment."
    echo "Run only on a fresh macOS install with backups in place."
    echo "============================================================"
    echo ""
    echo "=== Detected user configuration ==="
    echo "  Username: $USERNAME"
    echo "  Home:     $USERHOME"
    echo ""
    read -p "Continue? [Y/n] " response
    case "$response" in
    n | N)
        echo "Aborted. Update nix/common.local.nix manually and run again."
        exit 1
        ;;
    esac

    cat >"$LOCAL_CONFIG" <<EOF
{ pkgs, ... }: {
  users.users.user = {
    name = "$USERNAME";
    home = "$USERHOME";
  };
}
EOF
    echo "Created nix/common.local.nix"
fi

echo ""
echo "Building and switching Nix-Darwin system generation..."
sudo -E nix run nix-darwin -- switch --flake "$DOTFILES_DIR/nix#system"
