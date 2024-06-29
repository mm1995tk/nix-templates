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
    mk-template-list = list:
      builtins.foldl' (acc: {
        name,
        description,
      }:
        acc
        // {
          ${name} = {
            path = ./${name};
            inherit description;
          };
        }) {}
      list;
  in
    {
      templates = mk-template-list [
        {
          name = "rust";
          description = "Rust Flake App";
        }
      ];

      defaultTemplate = self.templates.rust;
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.alejandra;
    });
}
