{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {self, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: {
      systems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];

      perSystem = {
        config,
        self',
        system,
        inputs',
        pkgs,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          localSystem = system;
          config = {
            allowUnfree = true;
            allowAliases = true;
          };

          overlays = [
            self.overlays.default
          ];
        };

        devShells = {
          default = pkgs.callPackage ./nix/devshell.nix {
            dev = true;
          };

          ci = pkgs.callPackage ./nix/devshell.nix {};
        };

        packages = {
          go = pkgs.callPackage ./nix/go-package.nix {};
        };

        formatter = inputs'.alejandra.packages.default;
      };

      flake = {
        overlays.default = import ./nix/overlay.nix self;
      };
    });
}
