{
  pkgs,
  sharedDeps,
  hPkgs,
}: let
  stack-wrapped = pkgs.symlinkJoin {
    name = "stack";
    paths = [pkgs.stack];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/stack \
        --add-flags "\
          --no-nix \
          --system-ghc \
          --no-install-ghc \
        "
    '';
  };
in
  pkgs.mkShell rec {
    buildInputs =
      sharedDeps
      ++ [
        hPkgs.ghc
        stack-wrapped
        hPkgs.ghcid
        hPkgs.fourmolu
        hPkgs.hlint
        hPkgs.haskell-language-server
        hPkgs.retrie
        pkgs.treefmt
      ];
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
  }
