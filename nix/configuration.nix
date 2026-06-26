{ ... }:

let
  localConfig = ./common.local.nix;

  fallbackConfig = { ... }: {
    users.users.user = {
      name = "user";
      home = "/Users/user";
    };
  };
in
{
  imports = [
    ./common.nix
    ./hardware/apple-silicon.nix
    (if builtins.pathExists localConfig then localConfig else fallbackConfig)
  ];
}
