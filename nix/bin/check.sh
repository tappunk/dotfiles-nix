#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NIX_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
FLAKE_REF="path:${NIX_DIR}"

echo "== nix flake show =="
nix flake show "$FLAKE_REF"

echo "== nix flake check =="
nix flake check "$FLAKE_REF"

echo "== nix eval darwin configuration =="
nix eval "$FLAKE_REF#darwinConfigurations.system.system" >/dev/null

echo "== local setup verification =="
"$SCRIPT_DIR/verify-setup.sh"

echo "== all local checks passed =="
