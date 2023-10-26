{
  description = "Build And Devshell For X";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };


  };

  outputs = { self, nixpkgs, utils, gomod2nix, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        graft = pkgs: pkg:
          pkg.override { buildGoModule = pkgs.buildGo121Module; };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              go = prev.go_1_21;
              go-tools = graft prev prev.go-tools;
              gotools = graft prev prev.gotools;
              gopls = graft prev prev.gopls;
            })
            gomod2nix.overlays.default
          ];
        };
      in
      rec {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Golang
            go
            go-tools
            gotools
            gopls
            gomod2nix.packages.${system}.default
          ];
        };
      });
}
