# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.locations.home;
in
{
  options = {
    profiles.locations.home = {
      enable = mkEnableOption "the profile for devices that are used in my home";
    };
  };

  config = mkIf cfg.enable {
    profiles.wireless.encryptedConfigs = [ ./wpa_supplicant.sops.conf ];
  };
}
