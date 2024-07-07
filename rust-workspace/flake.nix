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
  }: let
    project-name = "rust-workspace";
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [rust-overlay.overlays.default];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;

      cargoToml = pkgs.lib.importTOML ./Cargo.toml;
      rustBins = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

      rustPlatform = pkgs.makeRustPlatform {
        rustc = rustBins;
        cargo = rustBins;
      };

      createImage = app: name: let
        toml = pkgs.lib.importTOML ./${name}/Cargo.toml;
        value = pkgs.dockerTools.buildImage {
          name = name;
          tag = toml.package.version;
          created = "now";
          copyToRoot = pkgs.buildEnv {
            name = "image-${name}";
            paths = [
              app
            ];
            pathsToLink = ["/bin"];
          };

          config.Cmd = ["/bin/${name}"];
        };
      in "cp ${value} $out/images/${name}";
    in {
      packages = rec {
        default = app;

        app = rustPlatform.buildRustPackage {
          name = project-name;
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
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
        };

        dockerImages = pkgs.stdenv.mkDerivation {
          name = project-name;
          src = ./.;
          installPhase = ''
            mkdir -p "$out/images"
            ${builtins.concatStringsSep "\n" (map (createImage app) cargoToml.workspace.members)}
          '';
        };

        # nix build -o "treefmt.toml" .#treefmt で　treefmt.toml　を生成
        treefmt = treefmtEval.config.build.configFile;
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [];
        buildInputs = with pkgs;
          [
            rustBins
            evcxr
            bacon
          ]
          ++ (
            if pkgs.stdenv.isDarwin
            then [pkgs.darwin.apple_sdk.frameworks.SystemConfiguration]
            else []
          );
        DUMMY = "world";
      };

      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
