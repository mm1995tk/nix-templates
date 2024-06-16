{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [rust-overlay.overlays.default];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

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

        # nix build -o "treefmt.toml" .#treefmt で　treefmt.toml　を生成
        treefmt = treefmtEval.config.build.configFile;
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

      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
