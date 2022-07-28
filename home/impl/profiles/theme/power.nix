# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.theme.power;
in
{
  options = {
    profiles.theme.power = {
      brightnessOnAdapter = mkOption {
        type = types.ints.between 0 100;
        default = 50;
        description = ''
          The desired brightness of the built-in display when powered by a
          non-battery source, expressed as a percentage between 0 and 100. Only
          applies when a backlight device is available.
        '';
      };
    };
  };
}
