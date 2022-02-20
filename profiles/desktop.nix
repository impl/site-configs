# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ... }: with lib;
let
  cfg = config.profiles.desktop;
in
  {
    options = {
      profiles.desktop = {
        enable = mkEnableOption "the desktop profile";
      };
    };

    config = mkIf cfg.enable {
      profiles = {
        gui.enable = true;
        mdns.enable = true;
        physical.enable = true;
        printing.enable = true;
        sound.enable = true;
      };
    };
  }
