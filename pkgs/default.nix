# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, newScope }: lib.makeScope newScope (pkgs: {
  choysh = pkgs.callPackage ./choysh.nix { };
  gpg-hardcopy = pkgs.callPackage ./gpg-hardcopy.nix { };
})
