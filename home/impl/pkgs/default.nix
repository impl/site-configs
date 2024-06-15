# SPDX-FileCopyrightText: 2022-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, newScope }: lib.makeScope newScope (pkgs: {
  amethyst = pkgs.callPackage ./amethyst.nix { };
  bambu-studio = pkgs.callPackage ./bambu-studio.nix { };
  betterdisplay = pkgs.callPackage ./betterdisplay.nix { };
  buildBubblewrap = pkgs.callPackage ./build-bubblewrap.nix { };
  buildFirefoxUserScriptsExtension = pkgs.callPackage ./build-firefox-userscripts-extension { };
  deezer = pkgs.callPackage ./deezer.nix { };
  hclfmt = pkgs.callPackage ./hclfmt.nix { };
  karp = pkgs.callPackage ./karp.nix { };
  ttclient = pkgs.callPackage ./ttclient.nix { };
  xscreensaverDesktopItems = pkgs.callPackage ./xscreensaver-desktopitems.nix { };
})
