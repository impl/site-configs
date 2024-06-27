# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.theme.icons;
in
{
  options = {
    profiles.theme.icons = {
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          hicolor-icon-theme
        ];
        example = literalExpression ''
          [
            pkgs.papirus-icon-theme
          ]
        '';
        description = ''
          Packages to install as part of the icon configuration.
        '';
      };

      name = mkOption {
        type = types.str;
        default = "hicolor";
        example = "Papirus-Light";
        description = ''
          The icon theme to use.
        '';
      };
    };
  };

  config = mkIf machineConfig.profiles.gui.enable {
    home.packages = cfg.packages;
    gtk.iconTheme.name = cfg.name;
  };
}
