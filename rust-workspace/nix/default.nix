{
  project-name,
  rustBins,
  pkgs,
}: let
  rustPlatform = pkgs.makeRustPlatform {
    rustc = rustBins;
    cargo = rustBins;
  };
in
  rustPlatform.buildRustPackage {
    name = project-name;
    src = ../.;
    cargoLock.lockFile = ../Cargo.lock;
    nativeBuildInputs =
      (with pkgs; [
        pkg-config
        openssl
      ])
      ++ (
        if pkgs.stdenv.isDarwin
        then [pkgs.darwin.apple_sdk.frameworks.SystemConfiguration]
        else []
      );
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  }
