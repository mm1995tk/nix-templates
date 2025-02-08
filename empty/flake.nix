{
  description = "nix flake app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;
    in {
      packages = {
        treefmt = treefmtEval.config.build.configFile;
      };

      devShells = import ./shell.nix {
        inherit pkgs;
      };

      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
