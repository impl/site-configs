# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
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

      profiles.base.allowUnfreePackages = [
        pkgs.brscan5
        "brscan5-etc-files"
      ];

      hardware.sane = {
        enable = true;
        brscan5 = {
          enable = true;
          netDevices = {
            "mfp-storage-room" = {
              model = "DCP-L2540DW";
              nodename = "mfp-storage-room.local";
            };
          };
        };
      };
    })
  ]);
}
