{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-21.05";
    };

    site = {
      url = "github:impl/site-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ site, ... }: {
    nixosConfigurations = site.lib.mkNixosConfigurations {
      extraModules = [
        ./configuration.nix
      ];
    };
  };
}
