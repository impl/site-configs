# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
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
      services.tailscale.enable = true;
      services.openssh = {
        startWhenNeeded = true;
        openFirewall = mkDefault false;
      };

      networking.firewall = {
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
        checkReversePath = "loose";
      };
    }
    (mkIf (versionOlder config.system.nixos.release "22.11") {
      # Fixed in 22.11 by https://github.com/NixOS/nixpkgs/pull/178483
      networking.dhcpcd.denyInterfaces = [ config.services.tailscale.interfaceName ];

      systemd.network.networks."50-tailscale" = {
        matchConfig = {
          Name = config.services.tailscale.interfaceName;
        };
        linkConfig = {
          Unmanaged = true;
          ActivationPolicy = "manual";
        };
      };
    })
  ]);
}
