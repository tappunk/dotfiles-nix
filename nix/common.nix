{ config, pkgs, lib, inputs, muthr, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.enable = false;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableFastSyntaxHighlighting = true;
    enableAutosuggestions = true;
    
    interactiveShellInit = ''
      # Initialize FZF shell keybindings and fuzzy-completion matching rules natively
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # Highlight the current selected completion inside a visual grid on double-Tab
      zstyle ':completion:*' menu select

      # Enable smart, case-insensitive lookup routing (typing lowercase 'm' matches 'muthr')
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      
      # Setup fast substring-history keybindings for your Up/Down arrow blocks.
      # Typing a prefix and pressing Up Arrow filters exclusively through matches.
      autoload -Uz history-search-end
      zle -N history-beginning-search-backward-end history-search-end
      zle -N history-beginning-search-forward-end history-search-end
      bindkey "^[[A" history-beginning-search-backward-end
      bindkey "^[[B" history-beginning-search-forward-end
    '';
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    STARSHIP_CONFIG = "$HOME/dotfiles-nix/starship/starship.toml";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.activationScripts.applications.text = lib.mkForce ''
    echo "Skipping /Applications/Nix Apps symlinks (CLI setup)"
  '';

  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "=== Setting up user dotfile symlinks ==="
    userHome="${config.users.users.user.home}"

    mkdir -p "$userHome/.config/"{zsh,ghostty,eza,fastfetch}
    mkdir -p "$userHome/.lima"
    mkdir -p "$userHome/.cache/muthr"
    mkdir -p "$userHome/.cache/dotfiles" "$userHome/.cache/starship" "$userHome/.cache/uv"
    mkdir -p "$userHome/.config/opencode"
    mkdir -p "$userHome/opt/models"
    mkdir -p "$userHome/.local/bin"

    ln -sfn "$userHome/dotfiles-nix/nvim"                     "$userHome/.config/nvim"
    ln -sfn "$userHome/dotfiles-nix/fastfetch/config.jsonc"   "$userHome/.config/fastfetch/config.jsonc"
    ln -sfn "$userHome/dotfiles-nix/fastfetch/tappunk.txt"    "$userHome/.config/fastfetch/tappunk.txt"

    HOME="$userHome" ${muthr}/bin/muthr init --force

    ln -sfn "$userHome/dotfiles-nix/ghostty/config"           "$userHome/.config/ghostty/config"
    ln -sfn "$userHome/dotfiles-nix/eza/theme.yml"            "$userHome/.config/eza/theme.yml"
    ln -sfn "$userHome/dotfiles-nix/starship/starship.toml"   "$userHome/.config/starship.toml"

    ln -sfn "$userHome/dotfiles-nix/git/.gitconfig"           "$userHome/.gitconfig"
    ln -sfn "$userHome/dotfiles-nix/git/.gitignore_global"    "$userHome/.gitignore_global"
    ln -sfn "$userHome/dotfiles-nix/zsh/.zshrc"               "$userHome/.zshrc"
    ln -sfn "$userHome/dotfiles-nix/zsh/.zshenv"              "$userHome/.zshenv"
    ln -sfn "$userHome/dotfiles-nix/zsh/.zprofile"            "$userHome/.zprofile"

    mkdir -p "$userHome/.gnupg"
    echo "pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac" > "$userHome/.gnupg/gpg-agent.conf"

    if [ ! -f "$userHome/.npmrc" ] || ! grep -q 'prefix=~/.local/npm/globals' "$userHome/.npmrc"; then
        echo 'prefix=~/.local/npm/globals
cache=~/.local/npm/cache' > "$userHome/.npmrc"
    fi

    chown ${config.users.users.user.name}:staff "$userHome/.gitconfig" "$userHome/.gitignore_global" "$userHome/.zshrc" "$userHome/.zshenv" "$userHome/.zprofile" "$userHome/.npmrc" 2>/dev/null || true
    chown -R ${config.users.users.user.name}:staff "$userHome/.config" "$userHome/.cache" "$userHome/.cache/muthr" "$userHome/.lima" "$userHome/.gnupg" "$userHome/.local" 2>/dev/null || true

    echo "Dotfile symlinks completed cleanly for $userHome"
  '';

  environment.systemPackages = let
    opencode = pkgs.stdenvNoCC.mkDerivation {
      pname = "opencode";
      version = "v1.17.9";

      src = pkgs.fetchFromGitHub {
        owner = "anomalyco";
        repo = "opencode";
        tag = "v1.17.9";
        hash = "sha256-OWfI2dp0PeNShVZMzEdm69EtxWX7UwmyPmX02SfrjP8=";
      };

      nativeBuildInputs = with pkgs; [ bun nodejs git ripgrep sysctl makeBinaryWrapper installShellFiles ];

      preHook = ''
        export OPENCODE_VERSION="1.17.9"
        export OPENCODE_DISABLE_MODELS_FETCH="true"
        export HOME=$TMPDIR
        export BUN_TMPDIR=$TMPDIR
        export BUN_INSTALL=$TMPDIR/.bun
      '';

      postPatch = ''
        # Patch opencode to downgrade the Bun version requirement error to a warning
        substituteInPlace packages/script/src/index.ts \
          --replace-fail 'throw new Error(`This script requires bun@''${expectedBunVersionRange}' \
                           'console.warn(`Warning: This script requires bun@''${expectedBunVersionRange}'
      '';

      buildPhase = ''
        bun install \
          --cpu="*" \
          --frozen-lockfile \
          --filter ./ \
          --filter ./packages/app \
          --filter ./packages/desktop \
          --filter ./packages/opencode \
          --filter ./packages/shared \
          --ignore-scripts \
          --no-progress \
          --os="*"

        bun --bun ./nix/scripts/normalize-bun-binaries.ts

        cd ./packages/opencode
        bun --bun ./script/build.ts --single --skip-install
        bun --bun ./script/schema.ts config.json tui.json
      '';

      installPhase = ''
        install -Dm755 dist/opencode-*/bin/opencode $out/bin/opencode
        wrapProgram $out/bin/opencode \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ripgrep ]} \
          --set OPENCODE_DISABLE_AUTOUPDATE true

        install -Dm644 config.json $out/share/opencode/config.json
        install -Dm644 tui.json $out/share/opencode/tui.json
      '';

      postInstall = pkgs.lib.optionalString (pkgs.stdenvNoCC.hostPlatform.isDarwin) ''
        installShellFiles --cmd opencode \
          --bash <($out/bin/opencode completion) \
          --zsh <(SHELL=/bin/zsh $out/bin/opencode completion)
      '';

      doInstallCheck = true;
      installCheckPhase = "$out/bin/opencode --version";
    };

    llama-cpp = pkgs.stdenv.mkDerivation {
      pname = "llama-cpp";
      version = "b9758";

      src = pkgs.fetchurl {
        url = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b9758.tar.gz";
        hash = "sha256-QoCvgjAwkps2tUtdUrKUjlILUh+eHwerwxXkrCYqwR4=";
      };

      nativeBuildInputs = with pkgs; [ pkg-config cmake ];
      buildInputs = with pkgs; [ curl ];

      cmakeFlags = [
        "-DGGML_METAL_EMBED_LIBRARY=ON"
        "-DGGML_LTO=ON"
        "-DLLAMA_CURL=ON"
        "-DLLAMA_ACCELERATE=ON"
        "-DLLAMA_SERVER_WEBUI=OFF"
        "-DCMAKE_INCLUDE_OUTPUT_DIRECTORY=include"
        "-DBUILD_SHARED_LIBS=OFF"
      ];

      installPhase = ''
        mkdir -p $out/bin

        cp bin/* $out/bin/ 2>/dev/null || cp build/bin/* $out/bin/

        if [ -f $out/bin/llama-cli ]; then
          ln -sf $out/bin/llama-cli $out/bin/llama-cpp
        fi
      '';
    };

  in with pkgs; [
    # Global CLI Utils
    wget stow delta bat eza fd ripgrep zoxide fastfetch fzf glow jq starship
    macmon lima neovim yazi rsync uv gh exiftool imagemagick asciinema agg
    ffmpeg tmux

    # Runtimes & Engineering Toolchains
    python3 nodejs rustc cargo clippy rustfmt
    lua-language-server bash-language-server vscode-langservers-extracted
    yaml-language-server marksman pyright clang-tools typescript-language-server

    # Formatters & Linters
    prettierd black isort shfmt stylua taplo

    # Credentials & Git Channels
    gnupg pinentry_mac pwgen (pass.withExtensions (exts: [ exts.pass-otp ]))
    git lazygit

    # MCP Servers (nixpkgs — SHA256 verified)
    mcp-server-memory
    mcp-server-filesystem
    mcp-server-sequential-thinking

    # Shared Custom Pinned Compilations
    opencode
    llama-cpp
    muthr
    inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.hunk
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  environment.pathsToLink = [ "/share/zsh/plugins" "/share/zsh-syntax-highlighting" ];

  system.stateVersion = 6;
}
