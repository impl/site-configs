# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

build: build "25.11" {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
  ];
}
