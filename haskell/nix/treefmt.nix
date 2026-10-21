{ pkgs, ... }: {
  projectRootFile = "flake.nix";
  enableDefaultExcludes = true;
  settings.global.excludes = [
    ".direnv/*"
    ".stack-work/*"
    "result/*"
  ];
  programs.nixfmt.enable = true;
  programs.fourmolu.enable = true;
  programs.yamlfmt.enable = true;
}
