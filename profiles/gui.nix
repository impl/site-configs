# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.gui;
in
{
  options = {
    profiles.gui = {
      enable = mkEnableOption "the GUI (X11) profile";
    };
  };

  config = mkIf cfg.enable {
    profiles = {
      userInteractive.enable = true;
    };

    services.xserver = {
      enable = true;
      layout = "us";
      libinput.enable = true;
      desktopManager = {
        xterm = {
          enable = true;
        };
      };
    };

    services.gvfs.enable = true;
  };
}
