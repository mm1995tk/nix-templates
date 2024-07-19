{
  pkgs,
  ghc,
  sharedDeps,
}:
pkgs.haskell.lib.buildStackProject {
  inherit ghc;
  src = ../.;
  name = packageYaml.name;
  buildInputs = sharedDeps;
}
