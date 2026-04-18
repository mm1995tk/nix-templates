{
  pkgs,
  project-name,
  ...
}: let
  goEnv = pkgs.mkGoEnv {pwd = ./.;};
in {
  default = pkgs.mkShell {
    buildInputs = [
      goEnv
      pkgs.gomod2nix
    ];

    PROJECT_NAME = project-name;
  };
}
