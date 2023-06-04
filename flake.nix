# SPDX-FileCopyrightText: 2021-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  inputs = {
    dwarffs = {
      url = "github:edolstra/dwarffs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-sops = {
      url = "github:impl/nix-sops";
    };

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    nixpkgs_2305 = {
      url = "github:nixos/nixpkgs/nixos-23.05";
    };

    systemd-user-sleep = {
      url = "github:impl/systemd-user-sleep";
    };
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      lib = import ./lib {
        inherit inputs;
        lib = nixpkgs.lib;
      };

      machines = lib.importDir ./machines;
      homes = lib.importDir ./home;

      nixosConfigurations = lib.mkNixosConfigurations machines;
      homeConfigurations = lib.mkHomeConfigurations homes nixosConfigurations;
    in
    {
      inherit lib nixosConfigurations homeConfigurations;

      # Create installer packages for each system type we define.
      packages = with nixpkgs.lib; mapAttrs' (_: nixosConfiguration: let
        system = nixosConfiguration.config.nixpkgs.system;
        installerConfiguration = lib.mkNixosConfiguration (build: build "23.05" {
          inherit system;
          modules = [
            ./installer
          ];
        });
      in nameValuePair system {
        installer = installerConfiguration.config.system.build.isoImage;
      }) nixosConfigurations;

      templates = rec {
        machine = {
          description = "A machine to use with the profiles in this repository";
          path = ./templates/machine;
        };
        default = machine;
      };
    };
}
