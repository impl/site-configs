# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, libX, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  xsession.windowManager = {
    xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPkgs: with haskellPkgs; [ dbus ];
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

  systemd.user.services.xmonad = {
    Unit = {
      Description = "Xmonad";
      PartOf = [ "hm-graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "hm-graphical-session.target" ];
    };

    Service = let
      target = "${config.home.homeDirectory}/${config.home.file.".xmonad/xmonad-${pkgs.stdenv.hostPlatform.system}".target}";
    in {
      Type = "dbus";
      BusName = "com.noahfontes.site.wm.Log";
      ExecStart = target;
      ExecReload = "${target} --restart";
      Restart = "on-failure";
    };
  };

  # When Xmonad is supervised by systemd, it needs to know about $PATH because
  # e.g. Rofi transitively depends on it.
  xsession.importedVariables = [ "PATH" ];
}
