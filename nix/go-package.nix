{buildGoModule, ...}:
buildGoModule {
  name = "x";

  src = ../.;

  vendorHash = null;
}
