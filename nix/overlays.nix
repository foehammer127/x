{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;

  importLocalOverlay = file:
    lib.composeExtensions
    (_: _: {__inputs = inputs;})
    (import (../overlays + "/${file}"));

  localOverlays =
    lib.mapAttrs' (
      f: _:
        lib.nameValuePair
        (lib.removeSuffix ".nix" f)
        (importLocalOverlay f)
    )
    (builtins.readDir ../overlays);
in
  localOverlays
  // {
    default = lib.attrValues localOverlays;
  }
