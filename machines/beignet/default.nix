# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ nix-sops_2205, nixpkgs_2205, ... }: nixpkgs_2205.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    nix-sops_2205.nixosModules.default
    ./configuration.nix
  ];
}
