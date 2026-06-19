export PAGER='less'
export COLORTERM="truecolor"
export XDG_CONFIG_HOME="$HOME/.config"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export STARSHIP_CONFIG="$HOME/dotfiles-nix/starship/starship.toml"

export UV_TOOL_BIN_DIR="$HOME/.local/bin"

if [[ -d "$HOME/.local/bin" ]]; then
    path=("$HOME/.local/bin" $path)
fi
