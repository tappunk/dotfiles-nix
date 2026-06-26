{ pkgs, config, ... }:
{
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    STARSHIP_CONFIG = "${config.users.users.user.home}/dotfiles-nix/starship/starship.toml";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableFastSyntaxHighlighting = true;
    enableAutosuggestions = true;

    interactiveShellInit = ''
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      autoload -Uz history-search-end
      zle -N history-beginning-search-backward-end history-search-end
      zle -N history-beginning-search-forward-end history-search-end
      bindkey "^[[A" history-beginning-search-backward-end
      bindkey "^[[B" history-beginning-search-forward-end
    '';
  };

  environment.pathsToLink = [ "/share/zsh/plugins" "/share/zsh-syntax-highlighting" ];
}
