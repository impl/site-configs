# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, newScope }: lib.makeScope newScope (pkgs: {
  buildBubblewrap = pkgs.callPackage ./build-bubblewrap.nix { };
  buildFirefoxUserScriptsExtension = pkgs.callPackage ./build-firefox-userscripts-extension { };
  deezer = pkgs.callPackage ./deezer.nix { };
  hclfmt = pkgs.callPackage ./hclfmt.nix { };
  karp = pkgs.callPackage ./karp.nix { };
  xscreensaverDesktopItems = pkgs.callPackage ./xscreensaver-desktopitems.nix { };
})
