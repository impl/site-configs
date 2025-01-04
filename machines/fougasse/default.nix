# SPDX-FileCopyrightText: 2022-2025 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

build: build "24.11" {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
  ];
}
