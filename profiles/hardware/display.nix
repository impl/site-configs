# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.display;
in
{
  options = {
    profiles.hardware.display = {
      internal = {
        edid = mkOption {
          type = types.nullOr (types.strMatching "[0-9a-f]*");
          default = null;
          description = ''
            The hexadecimal-encoded EDID string for the internal display.
          '';
        };
      };
    };
  };
}
