# SPDX-FileCopyrightText: 2022-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, pkgsUnstable, ... }: with lib;
let
  cfg = config.profiles.locations.vpn;
in
{
  options = {
    profiles.locations.vpn = {
      enable = mkEnableOption "the profile for devices that are connected with a VPN";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.tailscale = {
        enable = true;
        package = pkgsUnstable.tailscale;
      };
    }
    (optionalAttrs (class == "nixos") {
      services.openssh = {
        startWhenNeeded = true;
        openFirewall = mkDefault false;
      };

      networking.firewall = {
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
        checkReversePath = "loose";
      };
    })
  ]);
}
