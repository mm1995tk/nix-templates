{
  description = "gomod2nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # if you want to use a stable release, you can uncomment the line below and comment the line above.
    #nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
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

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./flake-treefmt.nix;

      appsDrv = pkgs.buildGoApplication {
        pname = "go";
        version = "0.1";
        pwd = ./.;
        src = ./.;
        modules = ./gomod2nix.toml;
      };

      drvSet = my-utils.from-multi-bins-drv-to-drvset {
        drv = appsDrv;
        path-apps-dir = ./cmd;
      };
    in {
      packages =
        drvSet
        // (import ./flake-task.nix {})
        // {
          default = appsDrv;
          treefmt = treefmtEval.config.build.configFile;
          images = import ./nix/container.nix {
            apps = drvSet;
            inherit project-name pkgs my-utils;
          };
        };

      devShells = import ./flake-shell.nix {inherit pkgs project-name;};
      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
