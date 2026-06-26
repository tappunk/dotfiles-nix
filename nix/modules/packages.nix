{ pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;

  muthr = inputs.muthr.packages.${system}.default;

  opencode = pkgs.stdenvNoCC.mkDerivation {
    pname = "opencode";
    version = "v1.17.11";

    src = pkgs.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v1.17.11";
      hash = "sha256-ZgmRHoI3rxsSM10sA4cZu/FxqwmgawQvlW3eykXQsqQ=";
    };

    nativeBuildInputs = with pkgs; [ bun nodejs git ripgrep sysctl makeBinaryWrapper installShellFiles ];

    preHook = ''
      export OPENCODE_VERSION="1.17.11"
      export OPENCODE_DISABLE_MODELS_FETCH="true"
      export HOME=$TMPDIR
      export BUN_TMPDIR=$TMPDIR
      export BUN_INSTALL=$TMPDIR/.bun
    '';

    postPatch = ''
      substituteInPlace packages/script/src/index.ts \
        --replace-fail 'throw new Error(`This script requires bun@''${expectedBunVersionRange}' \
        'console.warn(`Warning: This script requires bun@''${expectedBunVersionRange}'
    '';

    buildPhase = ''
      bun install \
        --cpu="*" \
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

    postInstall = pkgs.lib.optionalString pkgs.stdenvNoCC.hostPlatform.isDarwin ''
      installShellFiles --cmd opencode \
        --bash <($out/bin/opencode completion) \
        --zsh <(SHELL=/bin/zsh $out/bin/opencode completion)
    '';

    doInstallCheck = true;
    installCheckPhase = "$out/bin/opencode --version";
  };

  llama-cpp = pkgs.stdenv.mkDerivation {
    pname = "llama-cpp";
    version = "b9813";

    src = pkgs.fetchurl {
      url = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b9813.tar.gz";
      hash = "sha256-Z2Xx91QKNqTUWmqSga/Xv11bRbHTDwevlEoCsxKMNmc=";
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
in
{
  environment.systemPackages = with pkgs; [
    wget stow delta bat eza fd ripgrep zoxide fastfetch fzf glow jq starship
    macmon lima neovim yazi rsync uv gh exiftool imagemagick asciinema-agg
    ffmpeg tmux

    python3 nodejs rustc cargo clippy rustfmt
    lua-language-server bash-language-server vscode-langservers-extracted
    yaml-language-server marksman pyright clang-tools typescript-language-server

    prettierd black isort shfmt stylua taplo

    gnupg pinentry_mac pwgen (pass.withExtensions (exts: [ exts.pass-otp ]))
    git lazygit

    mcp-server-memory
    mcp-server-filesystem
    mcp-server-sequential-thinking

    opencode
    llama-cpp
    muthr
    inputs.hunk.packages.${system}.hunk
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}
