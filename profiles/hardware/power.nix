# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.power;
in
{
  options = {
    profiles.hardware.power = {
      adapter = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "AC";
        description = ''
          The power supply adapter that is responsible for providing charging
          power to this machine.
        '';
      };

      batteries = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "BAT0" ];
        description = ''
          The power supply batteries attached to this machine.
        '';
      };
    };
  };
}
