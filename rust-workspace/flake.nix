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
      project-name = builtins.baseNameOf ./.;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [rust-overlay.overlays.default];
      };
      
      my-utils = import ./nix/utils.nix {inherit pkgs;};

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;

      rustBins = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

      drv = import ./nix {
        inherit rustBins;
        inherit project-name;
        inherit pkgs;
      };

      drvAttrsSet = my-utils.from-multi-bins-drv-to-drvset {
        inherit drv;
        path-apps-dir = ./apps;
      };
    in {
      packages =
        drvAttrsSet
        // {
          default = drv;

          images = import ./nix/container.nix {
            inherit project-name;
            inherit pkgs;
            apps = drvAttrsSet;
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
