# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.locations.home;
in
{
  options = {
    profiles.locations.home = {
      enable = mkEnableOption "the profile for devices that are used in my home";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (class == "nixos") {
      profiles.wireless.encryptedConfigs = [ ./wpa_supplicant.sops.conf ];
    })
  ]);
}
