{pkgs}:
pkgs.buildGoApplication {
  pname = "go";
  version = "0.1";
  pwd = ../.;
  src = ../.;
  modules = ../gomod2nix.toml;
}
