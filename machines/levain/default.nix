# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ nixos_2511, ... }: nixos_2511 {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
  ];
}
