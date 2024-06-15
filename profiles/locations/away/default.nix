# SPDX-FileCopyrightText: 2023-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.locations.away;
in
{
  options = {
    profiles.locations.away = {
      enable = mkEnableOption "the profile for devices that are taken on the road";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (class == "nixos") {
      profiles.wireless.encryptedConfigs = [ ./wpa_supplicant.sops.conf ];
    })
  ]);
}
