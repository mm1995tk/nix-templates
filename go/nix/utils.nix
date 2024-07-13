{pkgs}: {
  # drv -> AttrSet<string, drv> | 複数のバイナリを生成するderivationを複数のderivationに分割する
  from-multi-bins-drv-to-drvset = {
    drv,
    path-apps-dir,
  }:
    builtins.foldl' (acc: appName:
      acc
      // {
        ${appName} = pkgs.stdenv.mkDerivation {
          name = appName;
          src = ./.;
          installPhase = ''
            mkdir -p "$out/bin"
            cp ${drv}/bin/${appName} $out/bin
          '';
        };
      }) {} (builtins.attrNames (builtins.readDir path-apps-dir));
}
