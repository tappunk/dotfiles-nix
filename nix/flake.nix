{
  description = "System Flake - Unstable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    muthr.url = "github:tappunk/muthr/main";
    muthr.inputs.nixpkgs.follows = "nixpkgs";

    hunk.url = "github:modem-dev/hunk";
    hunk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, ... }:
    let
      darwinConfig = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs self;
        };
        modules = [ ./configuration.nix ];
      };

      hostSystem = darwinConfig.pkgs.stdenv.hostPlatform.system;
    in
    {
      darwinConfigurations."system" = darwinConfig;

      darwinPackages = darwinConfig.pkgs;
      packages.${hostSystem}.darwin-rebuild = nix-darwin.packages.${hostSystem}.darwin-rebuild;
    };
}
