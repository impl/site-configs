# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, libX, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.theme.colors;
in
{
  options = {
    theme.colors = {
      primary = mkOption {
        type = libX.colors.type;
        example = literalExpression ''libX.colors.hex "#ffab1234"'';
        description = ''
          The primary interface color.
        '';
      };

      secondary = mkOption {
        type = libX.colors.type;
        example = literalExpression ''libX.colors.hex "#abcdef"'';
        description = ''
          The secondary interface color.
        '';
      };

      text = mkOption {
        type = libX.colors.type;
        default = libX.colors.rgb 0 0 0;
        example = literalExpression ''libX.colors.hex "#222222"'';
        description = ''
          The main text color.
        '';
      };

      urgent = mkOption {
        type = libX.colors.type;
        default = libX.colors.rgb 255 0 0;
        example = literalExpression ''libX.colors.hex "#ff0000"'';
        description = ''
          A color for urgent notifications.
        '';
      };
    };
  };
}
