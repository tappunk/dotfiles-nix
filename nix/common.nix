{ ... }:
{
  imports = [
    ./modules/base.nix
    ./modules/security.nix
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/dotfiles-links.nix
  ];
}
