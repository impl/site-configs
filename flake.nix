# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  inputs = {
    dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin_2605 = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs_2605_darwin";
    };

    nix-flatpak = {
      url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";
    };

    nix-sops = {
      url = "github:impl/nix-sops";
    };

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    nixos_2605 = {
      url = "github:nixos/nixpkgs/nixos-26.05";
    };

    nixpkgs_2605_darwin = {
      url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    };

    nur = {
      url = "github:nix-community/NUR";
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
      machineConfigurations = lib.mkMachineConfigurations machines;
      machineOutputs = lib.mkMachineOutputs machineConfigurations;

      homes = lib.importDir ./home;
      homeConfigurations = lib.mkHomeConfigurations homes machineConfigurations;
    in
    {
      inherit lib homeConfigurations;

      # Create installer packages for each system type we define.
      packages = with nixpkgs.lib; mapAttrs'
        (_: nixosConfiguration:
          let
            system = nixosConfiguration.config.nixpkgs.system;
            installerConfiguration = lib.machines.mkMachineConfiguration ({ nixos_2605, ...}: nixos_2605 {
              inherit system;
              modules = [
                ./installer
              ];
            });
          in
          nameValuePair system {
            installer = installerConfiguration.config.system.build.isoImage;
          })
        machineOutputs.nixosConfigurations;

      templates = rec {
        machine = {
          description = "A machine to use with the profiles in this repository";
          path = ./templates/machine;
        };
        default = machine;
      };
    } // machineOutputs;
}
