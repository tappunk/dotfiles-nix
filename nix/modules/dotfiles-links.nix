{ config, pkgs, inputs, lib, ... }:
let
  userName = config.users.users.user.name;
  userHome = config.users.users.user.home;
  dotfilesDir = "${userHome}/dotfiles-nix";
  muthr = inputs.muthr.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  system.activationScripts.applications.text = lib.mkForce ''
    echo "Skipping /Applications/Nix Apps symlinks (CLI setup)"
  '';

  system.activationScripts.dotfilesDirs.text = lib.mkAfter ''
    mkdir -p "${userHome}/.config/"{zsh,ghostty,eza,fastfetch}
    mkdir -p "${userHome}/.cache/muthr"
    mkdir -p "${userHome}/.cache/dotfiles" "${userHome}/.cache/starship" "${userHome}/.cache/uv"
    mkdir -p "${userHome}/.config/opencode"
    mkdir -p "${userHome}/opt/models"
    mkdir -p "${userHome}/.local/bin"
    mkdir -p "${userHome}/.gnupg"
  '';

  system.activationScripts.dotfilesLinks.text = lib.mkAfter ''
    echo "=== Setting up user dotfile symlinks ==="

    ln -sfn "${dotfilesDir}/nvim" "${userHome}/.config/nvim"
    ln -sfn "${dotfilesDir}/fastfetch/config.jsonc" "${userHome}/.config/fastfetch/config.jsonc"
    ln -sfn "${dotfilesDir}/fastfetch/tappunk.txt" "${userHome}/.config/fastfetch/tappunk.txt"

    ln -sfn "${dotfilesDir}/ghostty/config" "${userHome}/.config/ghostty/config"
    ln -sfn "${dotfilesDir}/eza/theme.yml" "${userHome}/.config/eza/theme.yml"
    ln -sfn "${dotfilesDir}/starship/starship.toml" "${userHome}/.config/starship.toml"

    ln -sfn "${dotfilesDir}/git/.gitconfig" "${userHome}/.gitconfig"
    ln -sfn "${dotfilesDir}/git/.gitignore_global" "${userHome}/.gitignore_global"

    if [ -d "${userHome}/.githooks" ] && [ ! -L "${userHome}/.githooks" ]; then
      backup_path="${userHome}/.cache/dotfiles/githooks-prelink-$(date +%Y%m%d%H%M%S)"
      mv "${userHome}/.githooks" "$backup_path"
      echo "Backed up existing ~/.githooks directory to $backup_path"
    fi

    ln -sfn "${dotfilesDir}/git/.githooks" "${userHome}/.githooks"
    ln -sfn "${dotfilesDir}/zsh/.zshrc" "${userHome}/.zshrc"
    ln -sfn "${dotfilesDir}/zsh/.zshenv" "${userHome}/.zshenv"
    ln -sfn "${dotfilesDir}/zsh/.zprofile" "${userHome}/.zprofile"

    echo "Dotfile symlinks completed cleanly for ${userHome}"
  '';

  system.activationScripts.muthrInit.text = lib.mkAfter ''
    HOME="${userHome}" ${muthr}/bin/muthr init --force
  '';

  system.activationScripts.gpgAgentPinentry.text = lib.mkAfter ''
    conf_file="${userHome}/.gnupg/gpg-agent.conf"
    managed_line="pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac"

    if [ -f "$conf_file" ]; then
      if grep -q '^pinentry-program ' "$conf_file"; then
        current_line="$(grep '^pinentry-program ' "$conf_file" | head -n1)"
        if [ "$current_line" != "$managed_line" ]; then
          cp "$conf_file" "${userHome}/.cache/dotfiles/gpg-agent.conf.backup-$(date +%Y%m%d%H%M%S)"
          tmp_conf="$(mktemp)"
          awk -v replacement="$managed_line" '
            BEGIN { replaced = 0 }
            /^pinentry-program / && replaced == 0 {
              print replacement
              replaced = 1
              next
            }
            { print }
          ' "$conf_file" > "$tmp_conf"
          mv "$tmp_conf" "$conf_file"
        fi
      else
        printf "\n%s\n" "$managed_line" >> "$conf_file"
      fi
    else
      printf "%s\n" "$managed_line" > "$conf_file"
    fi
  '';

  system.activationScripts.npmrcDefaults.text = lib.mkAfter ''
    npmrc_file="${userHome}/.npmrc"
    prefix_line='prefix=~/.local/npm/globals'
    cache_line='cache=~/.local/npm/cache'

    if [ ! -f "$npmrc_file" ]; then
      printf "%s\n%s\n" "$prefix_line" "$cache_line" > "$npmrc_file"
    else
      grep -q '^prefix=~/.local/npm/globals$' "$npmrc_file" || printf "%s\n" "$prefix_line" >> "$npmrc_file"
      grep -q '^cache=~/.local/npm/cache$' "$npmrc_file" || printf "%s\n" "$cache_line" >> "$npmrc_file"
    fi
  '';

  system.activationScripts.dotfilesOwnership.text = lib.mkAfter ''
    chown ${userName}:staff "${userHome}/.gitconfig" "${userHome}/.gitignore_global" "${userHome}/.githooks" "${userHome}/.zshrc" "${userHome}/.zshenv" "${userHome}/.zprofile" "${userHome}/.npmrc" 2>/dev/null || true
    chown -R ${userName}:staff "${userHome}/.config" "${userHome}/.cache" "${userHome}/.gnupg" "${userHome}/.local" 2>/dev/null || true
  '';
}
