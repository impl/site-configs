# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.theme.font;
in
{
  options = {
    profiles.theme.font = {
      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        example = literalExpression ''
          [
            pkgs.noto-sans
            pkgs.noto-sans-mono
          ]
        '';
        description = ''
          Packages to install as part of the font configuration.
        '';
      };

      generalFont = mkOption {
        type = types.str;
        default = "DejaVu Sans";
        example = "";
        description = ''
          The general font for UIs in a format interpretable by Fontconfig.
        '';
      };

      monospaceFont = mkOption {
        type = types.str;
        default = "DejaVu Sans Mono";
        description = ''
          The monospace font in a format interpretable by Fontconfig.
        '';
      };

      extraFonts = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [
          "Noto Sans Symbols"
          "Noto Sans Symbols2"
        ];
        description = ''
          Additional fonts to add to application support in a format
          interpretable by Fontconfig.
        '';
      };

      size = mkOption {
        type = types.int;
        default = 10;
        description = ''
          The system font size.
        '';
      };
    };
  };

  config = mkMerge [
    {
      fonts.fontconfig.enable = true;
      home.packages = cfg.packages;
    }
    (mkIf machineConfig.profiles.gui.enable {
      gtk.font = {
        name = cfg.generalFont;
        size = cfg.size;
      };
    })
  ];
}
