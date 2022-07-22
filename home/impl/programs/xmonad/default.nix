# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, libX, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  xsession.windowManager = {
    xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = with config.profiles.theme; with libX.colors; pkgs.substituteAll {
        src = ./config.hs;
        kitty = "${pkgs.kitty}/bin/kitty";
        rofi = "${pkgs.rofi}/bin/rofi";

        font = font.generalFont;
        fontSize = font.size;

        activeColor = toHex' colors.primary;
        activeTextColor = toHex' colors.text;
        inactiveColor = toHex' colors.secondary;
        inactiveTextColor =
          let
            text = scaleRGB (-20) colors.text;
          in toHex' (mostContrast [ text (invert text) ] colors.secondary);
        urgentColor = toHex' colors.urgent;
      };
    };
  };

  home.file.".xmonad/xmonad-${pkgs.hostPlatform.system}".force = true;
}
