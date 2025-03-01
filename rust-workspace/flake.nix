{
  description = "rust workspace flake app";

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

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;

      rustBins = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
        extensions = [
          # rust analyzerがstdライブラリを読み込むため
          "rust-src"
        ];
      };

    in {
      packages = import ./nix/package.nix {
        inherit rustBins;
        project-name = builtins.baseNameOf ./.;
        inherit pkgs;

        # treefmt.toml　を生成
        treefmtConfigFile = treefmtEval.config.build.configFile;
      };

      devShells.default = import ./shell.nix {
        inherit rustBins;
        inherit pkgs;
      };

      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
