{
  project-name,
  apps,
  pkgs,
  my-utils,
}: let
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
    key,
    value,
  }:
    acc
    + "\n"
    + (let
      toml = pkgs.lib.importTOML ../apps/${key}/Cargo.toml;
      image = buildImage {
        inherit key;
        tag = toml.package.version;
        app = value;
      };
    in "cp ${image} $out/images/${key}");
in
  pkgs.stdenv.mkDerivation {
    name = project-name;
    src = ../.;
    installPhase = ''
      mkdir -p "$out/images"
      ${builtins.foldl' generateScript "" (my-utils.attrsToList apps)}
    '';
  }
