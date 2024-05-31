{
  pkgs,
  lib,
  dev ? false,
  ...
}: let
  inherit (lib) optionals;

  devPackages = with pkgs; [
    just

    # Go Tools
    go
    go-tools
    gotools
    gopls
  ];

  packages = [] ++ optionals dev devPackages;
in
  pkgs.mkShell {
    inherit packages;
  }
