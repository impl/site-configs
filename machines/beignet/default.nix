# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

build: build "22.11" {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
  ];
}
