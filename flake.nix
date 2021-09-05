# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    nur = {
      url = "github:nix-community/NUR";
    };

    nix-sops = {
      url = "github:impl/nix-sops";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib.extend (final: prev: {
        my = import ./lib {
          inherit inputs;
          lib = final;
        };

        hm = home-manager.lib.hm;
      });

      # Default NixOS configurations. Usually extended using custom
      # `lib.mkNixosConfigurations`.
      nixosConfigurations = lib.my.mkNixosConfigurations {};

      # Default Home Manager configurations. Generally fine as-is because
      # Home Manager doesn't need to know about host hardware.
      homeConfigurations = lib.my.mkHomeConfigurations nixosConfigurations;
    in
    {
      inherit nixosConfigurations homeConfigurations;

      lib = lib.my;

      # These templates should be used when building a new machine to reference
      # the repo.
      templates = {
        machine = {
          description = "A machine declared in the machines directory of this repository";
          path = ./templates/machine;
        };
      };

      defaultTemplate = self.templates.machine;
    };
}
