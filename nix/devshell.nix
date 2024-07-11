{pkgs, ...}: let
  packages = with pkgs; [
    just

    # Go Tools
    go
    go-tools
    gotools
    gopls
  ];
in
  pkgs.mkShell {
    inherit packages;
  }
