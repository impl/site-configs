# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
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
    hardware.sane = {
      enable = true;
      extraBackends = with pkgs; [ sane-airscan ];
    };

    users.groups = genAttrs [ "lp" "scanner" ]
      (_: {
        members = mapAttrsToList
          (n: u: u.name)
          (filterAttrs (n: u: u.isNormalUser) config.users.users);
      });

    services.printing.enable = true;
  };
}
