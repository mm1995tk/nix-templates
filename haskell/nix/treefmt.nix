{pkgs, ...}: {
  projectRootFile = "flake.nix";
  enableDefaultExcludes = true;
  settings.global.excludes = [
    ".direnv/*"
    ".stack-work/*"
    "result/*"
  ];
  programs.alejandra.enable = true;
  programs.fourmolu.enable = true;
  programs.yamlfmt.enable = true;
}
