# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.locations.away;
in
{
  options = {
    profiles.locations.away = {
      enable = mkEnableOption "the profile for devices that are taken on the road";
    };
  };

  config = mkIf cfg.enable {
    profiles.wireless.encryptedConfigs = [ ./wpa_supplicant.sops.conf ];
  };
}
