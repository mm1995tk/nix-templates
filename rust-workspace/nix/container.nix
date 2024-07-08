{
  project-name,
  apps,
  pkgs,
}: let
  attrsToList = attrs:
    map (key: {
      name = key;
      app = attrs.${key};
    }) (builtins.attrNames attrs);

  buildImage = {
    name,
    tag,
    app,
  }:
    pkgs.dockerTools.buildImage {
      inherit name;
      inherit tag;
      created = "now";
      copyToRoot = pkgs.buildEnv {
        name = "image-${name}";
        paths = [app];
        pathsToLink = ["/bin"];
      };

      config.Cmd = ["/bin/${name}"];
    };

  generateScript = acc: {
    name,
    app,
  }:
    acc
    + "\n"
    + (let
      toml = pkgs.lib.importTOML ../apps/${name}/Cargo.toml;
      image = buildImage {
        inherit name;
        tag = toml.package.version;
        inherit app;
      };
    in "cp ${image} $out/images/${name}");
in
  pkgs.stdenv.mkDerivation {
    name = project-name;
    src = ../.;
    installPhase = ''
      mkdir -p "$out/images"
      ${builtins.foldl' generateScript "" (attrsToList apps)}
    '';
  }
