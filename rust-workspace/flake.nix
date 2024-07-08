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
    appNames = builtins.attrNames (builtins.readDir ./apps);
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [rust-overlay.overlays.default];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;

      cargoToml = pkgs.lib.importTOML ./Cargo.toml;
      rustBins = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

      app = import ./nix {
        inherit rustBins;
        inherit project-name;
        inherit pkgs;
      };

      each-derivation = builtins.foldl' (acc: appName:
        acc
        // {
          ${appName} = pkgs.stdenv.mkDerivation {
            name = appName;
            src = ./.;
            installPhase = ''
              mkdir -p "$out/bin"
              cp ${app}/bin/${appName} $out/bin
            '';
          };
        }) {}
      appNames;
    in {
      packages =
        each-derivation // {
          default = app;

          inherit app;

          dockerImages = import ./nix/container.nix {
            inherit project-name;
            apps = each-derivation;
          };

          # nix build -o "treefmt.toml" .#treefmt で　treefmt.toml　を生成
          treefmt = treefmtEval.config.build.configFile;
        };

      devShells.default = import ./nix/shell.nix {
        inherit rustBins;
        inherit pkgs;
      };

      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
