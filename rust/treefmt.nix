{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs.alejandra.enable = true;
  programs.rustfmt.enable = true;
  programs.taplo.enable = true;
}