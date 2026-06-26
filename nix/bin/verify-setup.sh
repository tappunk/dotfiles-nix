#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NIX_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DOTFILES_DIR="$(cd -- "$NIX_DIR/.." && pwd)"

USER_HOME="$HOME"

require_path() {
  local path="$1"
  if [ ! -e "$path" ]; then
    echo "Missing required path: $path"
    return 1
  fi
}

require_symlink_target() {
  local link_path="$1"
  local expected_target="$2"
  if [ ! -L "$link_path" ]; then
    echo "Expected symlink but found something else: $link_path"
    return 1
  fi

  local actual_target
  actual_target="$(readlink "$link_path")"
  if [ "$actual_target" != "$expected_target" ]; then
    echo "Symlink target mismatch for $link_path"
    echo "  expected: $expected_target"
    echo "  actual:   $actual_target"
    return 1
  fi
}

echo "== Verifying expected runtime directories =="
require_path "$USER_HOME/.config"
require_path "$USER_HOME/.cache"
require_path "$USER_HOME/.gnupg"
require_path "$USER_HOME/.local/bin"

echo "== Verifying managed symlinks =="
require_symlink_target "$USER_HOME/.config/nvim" "$DOTFILES_DIR/nvim"
require_symlink_target "$USER_HOME/.config/ghostty/config" "$DOTFILES_DIR/ghostty/config"
require_symlink_target "$USER_HOME/.config/eza/theme.yml" "$DOTFILES_DIR/eza/theme.yml"
require_symlink_target "$USER_HOME/.config/starship.toml" "$DOTFILES_DIR/starship/starship.toml"
require_symlink_target "$USER_HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig"
require_symlink_target "$USER_HOME/.gitignore_global" "$DOTFILES_DIR/git/.gitignore_global"
require_symlink_target "$USER_HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc"
require_symlink_target "$USER_HOME/.zshenv" "$DOTFILES_DIR/zsh/.zshenv"
require_symlink_target "$USER_HOME/.zprofile" "$DOTFILES_DIR/zsh/.zprofile"

echo "== Verifying key tool availability =="
command -v muthr >/dev/null
command -v opencode >/dev/null
command -v nvim >/dev/null

echo "== Verifying declarative Touch ID config =="
if ! grep -q 'touchIdAuth = true;' "$NIX_DIR/modules/security.nix"; then
  echo "Missing Touch ID sudo setting in nix/modules/security.nix"
  exit 1
fi

echo "== Verification complete: all checks passed =="
