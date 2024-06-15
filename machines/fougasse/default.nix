# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ nixos_2311, ... }: nixos_2311 {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
  ];
}
