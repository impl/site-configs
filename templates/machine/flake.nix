# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-22.05";
    };

    site = {
      url = "github:impl/site-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { site, ... }: {
    nixosConfigurations = site.lib.overrideNixosConfigurations { modules = [ ./configuration.nix ]; } site.nixosConfigurations;
  };
}
