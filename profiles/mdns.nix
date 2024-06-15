# SPDX-FileCopyrightText: 2021-2025 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, ... }: with lib;
let
  cfg = config.profiles.mdns;
in
{
  options = {
    profiles.mdns = {
      enable = mkEnableOption "the mDNS profile";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (class == "nixos") {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
    })
  ]);
}
