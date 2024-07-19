{
  description = "gomod2nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
    gomod2nix.inputs.flake-utils.follows = "flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    gomod2nix,
    treefmt-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      project-name = "mm1995tk/go";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [gomod2nix.overlays.default];
      };

      my-utils = import ./nix/utils.nix {inherit pkgs;};

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;

      appsDrv = import ./nix {inherit pkgs;};

      drvSet = my-utils.from-multi-bins-drv-to-drvset {
        drv = appsDrv;
        path-apps-dir = ./cmd;
      };
    in {
      packages =
        drvSet
        // {
          default = appsDrv;
          treefmt = treefmtEval.config.build.configFile;
        };

      images = import ./nix/container.nix {
        inherit project-name;
        inherit pkgs;
        apps = drvSet;
        inherit my-utils;
      };

      devShells.default = import ./nix/shell.nix {
        inherit pkgs;
      };

      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
