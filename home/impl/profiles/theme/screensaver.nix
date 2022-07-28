# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.theme.screensaver;
in
{
  options = {
    profiles.theme.screensaver = {
      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        example = literalExpression ''
          [
            pkgsX.xscreensaverDesktopItems
          ]
        '';
        description = ''
          Packages to install as part of the screensaver configuration.
        '';
      };

      name = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "screensavers-xscreensaver-flyingtoasters";
        description = ''
          The screensaver to show, or null for a blank screen.
        '';
      };

      idleDelayMinutes = mkOption {
        type = types.int;
        default = 5;
        description = ''
          The number of minutes until the session should be considered idle and
          the screensaver activates.
        '';
      };
    };
  };

  config = {
    home.packages = cfg.packages;
  };
}
