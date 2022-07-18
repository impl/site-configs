# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, newScope }: lib.makeScope newScope (pkgs: {
  buildBubblewrap = pkgs.callPackage ./build-bubblewrap.nix {};
  deezer = pkgs.callPackage ./deezer.nix {};
  karp = pkgs.callPackage ./karp.nix {};
})
