# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ... }: with lib;
let
  cfg = config.profiles.printing;
in
{
  options = {
    profiles.printing = {
      enable = mkEnableOption "the printing profile";
    };
  };

  config = mkIf cfg.enable {
    services.printing.enable = true;
  };
}
