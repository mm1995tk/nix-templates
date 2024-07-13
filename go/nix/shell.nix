{pkgs}: let
  goEnv = pkgs.mkGoEnv {pwd = ../.;};
in
  pkgs.mkShell {
    buildInputs = [
      goEnv
      pkgs.gomod2nix
    ];
  }
