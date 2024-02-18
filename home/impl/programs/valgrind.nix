# SPDX-FileCopyrightText: 2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  home.packages = with pkgs; [
    (valgrind.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [
        # Support for XLAT
        (fetchpatch {
          url = "https://bugsfiles.kde.org/attachment.cgi?id=111298";
          sha256 = "sha256-Qb4jAej3Zigom8zgcgWgzlFXYozBg/5vmB1PiClbbec=";
        })
      ];
    }))
  ];
}
