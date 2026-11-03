# SPDX-FileCopyrightText: 2022-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, newScope }: lib.makeScope newScope (pkgs: {
  certdata-filter = pkgs.callPackage ./certdata-filter { };
  configobj-merge = pkgs.callPackage ./configobj-merge { };
  choysh = pkgs.callPackage ./choysh.nix { };
  gpg-hardcopy = pkgs.callPackage ./gpg-hardcopy.nix { };
})
