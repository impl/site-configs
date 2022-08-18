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

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
    services.openssh.openFirewall = mkDefault false;

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      checkReversePath = "loose";
    };
  };
}
