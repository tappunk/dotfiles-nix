{ ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.enable = false;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
  };

  system.stateVersion = 6;
}
