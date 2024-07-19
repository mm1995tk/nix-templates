{
  pkgs,
  sharedDeps,
  hPkgs,
  treefmtConfigFile,
}: let
  src = ../.;
  packageYaml = let
    json = pkgs.runCommand "yaml-to-json" {
      nativeBuildInputs = [pkgs.yq];
      inherit src;
    } "cat $src/package.yaml | yq > $out";
  in
    builtins.fromJSON (builtins.readFile json);

  my-utils = import ./utils.nix {inherit pkgs;};

  drv = pkgs.haskell.lib.buildStackProject {
    inherit src;
    name = packageYaml.name;
    buildInputs = sharedDeps;
    ghc = hPkgs.ghc;
  };

  drvAttrsSet = my-utils.from-multi-bins-drv-to-drvset {
    inherit drv;
    executables = packageYaml.executables;
  };
in
  drvAttrsSet
  // {
    default = drv;

    images = import ./container.nix {
      inherit pkgs packageYaml my-utils;
      apps = drvAttrsSet;
    };

    # nix build -o "treefmt.toml" .#treefmt で　treefmt.toml　を生成
    treefmt = treefmtConfigFile;
  }
