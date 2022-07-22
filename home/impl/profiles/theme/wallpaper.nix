# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.theme.wallpaper;
in
{
  options = {
    profiles.theme.wallpaper = {
      file = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          The path to the wallpaper to use.
        '';
      };
    };
  };
}
