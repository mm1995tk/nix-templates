{
  description = "A collection of flake templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    files = builtins.attrNames (builtins.readDir (builtins.filterSource (path: type: type == "directory" && baseNameOf path != ".git") ./.));
  in
    {
      templates = builtins.foldl' (acc: fileName:
        acc
        // {
          ${fileName} = let
            flakeNix = import ./${fileName}/flake.nix;
          in {
            path = ./${fileName};
            description =
              if builtins.hasAttr "description" flakeNix
              then flakeNix.description
              else "No description.";
          };
        }) {}
      files;

      defaultTemplate = self.templates.rust;
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.alejandra;
    });
}
