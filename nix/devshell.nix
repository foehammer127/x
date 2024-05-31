{pkgs, ...}: let
  basePackages = with pkgs; [
    just

    # Go Tools
    go
    go-tools
    gotools
    gopls
  ];

  packages = basePackages;
in
  pkgs.mkShell {
    inherit packages;
  }
