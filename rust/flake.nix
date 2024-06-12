{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [rust-overlay.overlays.default];
      };

      cargoToml = (pkgs.lib.importTOML ./Cargo.toml).package;
      rustBins = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

      rustPlatform = pkgs.makeRustPlatform {
        rustc = rustBins;
        cargo = rustBins;
      };
    in {
      packages = rec {
        default = app;

        app = rustPlatform.buildRustPackage {
          pname = cargoToml.name;
          version = cargoToml.version;
          cargoLock.lockFile = ./Cargo.lock;
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = with pkgs; [
            pkg-config
            openssl
          ];
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
        };

        dockerImage = pkgs.dockerTools.buildImage {
          name = cargoToml.name;
          tag = "latest";
          created = "now";
          copyToRoot = pkgs.buildEnv {
            name = "image-${cargoToml.name}";
            paths = [
              app
            ];
            pathsToLink = ["/bin"];
          };

          config.Cmd = ["/bin/${cargoToml.name}"];
        };
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [];
        buildInputs = with pkgs; [
          rustBins
          evcxr
          bacon
        ];
        DUMMY = "world";
      };

      formatter = pkgs.alejandra;
    });
}
