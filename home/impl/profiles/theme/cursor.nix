# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.theme.cursor;
in
{
  options = {
    theme.cursor = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = literalExpression "pkgs.gnome.adwaita-icon-theme";
        description = ''
          The package that contains the cursor theme.
        '';
      };

      name = mkOption {
        type = types.str;
        default = "hicolor";
        example = "Papirus-Light";
        description = ''
          The name of the cursor.
        '';
      };

      size = mkOption {
        type = types.int;
        default = 32;
        example = 16;
        description = ''
          The size of the pointer cursor.
        '';
      };
    };
  };

  config = mkIf machineConfig.profiles.gui.enable {
    home.packages = [ cfg.package ];
    home.pointerCursor = {
      inherit (cfg) package name size;
      x11.enable = true;
    };
  };
}
