# SPDX-FileCopyrightText: 2023-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.virtual.vmwareGuest;
in
{
  _class = "nixos";

  options = {
    profiles.hardware.virtual.vmwareGuest = {
      enable = mkEnableOption "the VMware guest profile";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.vmware.guest.enable = true;

    # Enable time synchronization with host.
    services.chrony = {
      enable = true;
      extraConfig = ''
        refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0 stratum 2
      '';
    };
  };
}
