{
  description = "System Flake - Unstable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    muthr.url = "github:tappunk/muthr/main";
    muthr.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, muthr, ... }:
  {
    darwinConfigurations."system" = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs self;
        muthr = muthr.packages.aarch64-darwin.default;
      };
      modules = [ ./configuration.nix ];
    };

    darwinPackages = self.darwinConfigurations."system".pkgs;
  };
}
