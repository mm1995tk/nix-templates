{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

      rust = {
        path = ./rust;
        description = "Rust Flake App";
      };
    };

    defaultTemplate = self.templates.rust;

  };
}