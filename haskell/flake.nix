{
  description = "haskell flake app";

  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;

      hPkgs = pkgs.haskell.packages."ghc966"; # need to match Stackage LTS version

      sharedDeps = [
        pkgs.zlib
      ];
    in {
      packages = import ./nix/package.nix {
        inherit pkgs sharedDeps hPkgs;

        # treefmt.toml　を生成
        treefmtConfigFile = treefmtEval.config.build.configFile;
      };
      devShells.default = import ./nix/shell.nix {inherit sharedDeps pkgs hPkgs;};
      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
