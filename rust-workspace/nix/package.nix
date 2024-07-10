{
  rustBins,
  project-name,
  pkgs,
  treefmtConfigFile,
}: let
  my-utils = import ./utils.nix {inherit pkgs;};

  drv = import ./build.nix {
    inherit rustBins;
    inherit project-name;
    inherit pkgs;
  };

  drvAttrsSet = my-utils.from-multi-bins-drv-to-drvset {
    inherit drv;
    path-apps-dir = ../apps;
  };
in
  drvAttrsSet
  // {
    default = drv;

    images = import ./container.nix {
      inherit project-name;
      inherit pkgs;
      apps = drvAttrsSet;
      inherit my-utils;
    };

    # nix build -o "treefmt.toml" .#treefmt で　treefmt.toml　を生成
    treefmt = treefmtConfigFile;
  }
