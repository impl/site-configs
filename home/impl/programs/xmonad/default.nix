# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  xsession.windowManager = {
    xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = pkgs.substituteAll {
        src = ./config.hs;
        kitty = "${pkgs.kitty}/bin/kitty";
        rofi = "${pkgs.rofi}/bin/rofi";
      };
    };
  };

  home.file.".xmonad/xmonad-${pkgs.hostPlatform.system}".force = true;
}
