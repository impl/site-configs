# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.theme.cursor;
in
{
  options = {
    profiles.theme.cursor = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = literalExpression "pkgs.adwaita-icon-theme";
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

  config = mkIf machineConfig.profiles.gui.enable (mkMerge [
    {
      home.packages = [ cfg.package ];
    }
    (optionalAttrs (class == "nixos") {
      home.pointerCursor = {
        inherit (cfg) package name size;
        x11.enable = true;
      };
    })
  ]);
}
