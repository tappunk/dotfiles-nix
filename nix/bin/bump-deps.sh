#!/usr/bin/env zsh

set -e

NIX_FILE="$HOME/dotfiles-nix/nix/common.nix"

prefetch_to_sri() {
    local url_target="$1"
    local unpack_flag="$2"

    local base32_hash
    base32_hash=$(nix-prefetch-url $unpack_flag "$url_target")

    local b64_hash
    b64_hash=$(nix-hash --type sha256 --to-base64 "$base32_hash")

    echo "sha256-${b64_hash}"
}

echo "==== Starting Pinned Dependency Upgrades ===="

echo "Checking OpenCode..."
OPENCODE_TAG=$(curl -s https://api.github.com/repos/anomalyco/opencode/releases/latest | jq -r .tag_name)
OPENCODE_VER=${OPENCODE_TAG#v}
echo "-> Latest Release Tag: $OPENCODE_TAG"
echo "-> Prefetching SRI hash..."
OPENCODE_HASH=$(prefetch_to_sri "https://github.com/anomalyco/opencode/archive/refs/tags/${OPENCODE_TAG}.tar.gz" "--unpack")
echo "-> Computed Hash: $OPENCODE_HASH"

echo "Checking Llama.cpp..."
LLAMA_TAG=$(curl -s https://api.github.com/repos/ggml-org/llama.cpp/releases/latest | jq -r .tag_name)
echo "-> Latest Release Tag: $LLAMA_TAG"
echo "-> Prefetching SRI hash..."
LLAMA_HASH=$(prefetch_to_sri "https://github.com/ggml-org/llama.cpp/archive/refs/tags/${LLAMA_TAG}.tar.gz")
echo "-> Computed Hash: $LLAMA_HASH"

echo "Patching $NIX_FILE..."

TMP_NIX=$(mktemp)

awk -v opencode_tag="$OPENCODE_TAG" -v opencode_ver="$OPENCODE_VER" -v opencode_hash="$OPENCODE_HASH" \
    -v llama_tag="$LLAMA_TAG" -v llama_hash="$LLAMA_HASH" \
    'BEGIN { in_opencode=0; in_llama=0 }

    /pname = "opencode";/    { in_opencode=1; in_llama=0 }
    /pname = "llama-cpp";/  { in_opencode=0; in_llama=1 }

    in_opencode == 1 {
        sub(/version = "[^"]+";/, "version = \"" opencode_tag "\";")
        sub(/tag = "[^"]+";/, "tag = \"" opencode_tag "\";")
        sub(/hash = "[^"]+";/, "hash = \"" opencode_hash "\";")
        sub(/OPENCODE_VERSION="[^"]+"/, "OPENCODE_VERSION=\"" opencode_ver "\"")
    }

    in_llama == 1 {
        sub(/version = "[^"]+";/, "version = \"" llama_tag "\";")
        sub(/url = "https:\/\/github\.com\/ggml-org\/llama\.cpp\/archive\/refs\/tags\/[^\"]+\.tar\.gz";/,
            "url = \"https://github.com/ggml-org/llama.cpp/archive/refs/tags/" llama_tag ".tar.gz\";")
        sub(/hash = "[^"]+";/, "hash = \"" llama_hash "\";")
    }

    /^    \};/ { in_opencode=0; in_llama=0 }

    { print $0 }' "$NIX_FILE" >"$TMP_NIX"

mv "$TMP_NIX" "$NIX_FILE"

echo "Updating muthr flake..."
cd "$HOME/dotfiles-nix/nix"
nix flake update muthr
echo "-> muthr flake updated"
cd "$HOME/dotfiles-nix"

echo "Verifying Nix configuration syntax..."
if nix-instantiate --parse "$NIX_FILE" >/dev/null; then
    echo "==== Success! Dependencies updated and Nix layout validated OK ===="
else
    echo "!!!! Warning: Script completed but validation failed. Verify your common.nix file manually !!!!"
    exit 1
fi

