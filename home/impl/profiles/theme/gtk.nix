# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.theme.gtk;
in
{
  options = {
    profiles.theme.gtk = {
      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        example = literalExpression ''
          [
            pkgs.adwaita-icon-theme
          ]
        '';
        description = ''
          Packages to install to provide GTK+ UI themes.
        '';
      };

      themeName = mkOption {
        type = types.str;
        default = "Adwaita";
        description = ''
          The GTK+ UI theme to use.
        '';
      };
    };
  };

  config = mkIf machineConfig.profiles.gui.enable {
    home.packages = cfg.packages;
    home.pointerCursor.gtk.enable = true;
    gtk = {
      enable = true;
      theme.name = cfg.themeName;
    };
  };
}
