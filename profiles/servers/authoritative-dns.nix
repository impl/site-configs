# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, libDNS, pkgs, ... }: with lib;
let
  cfg = config.profiles.servers.authoritativeDNS;
in
{
  options = {
    profiles.servers.authoritativeDNS = {
      enable = mkEnableOption "the authoritative DNS server profile";

      listenAddresses = mkOption {
        type = types.listOf types.str;
        description = ''
          The addresses to listen on, in ip@port format.
        '';
        default = [ ];
      };

      zones = mkOption {
        type = types.attrsOf libDNS.types.zone;
        description = ''
          The zones to serve.
        '';
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    services.knot = {
      enable = true;
      extraConfig = ''
        server:
          listen: ${builtins.toJSON cfg.listenAddresses}
        log:
        - target: syslog
          any: info
        zone:
        ${concatStringsSep "\n" (mapAttrsToList (domain: zone: ''
          - domain: ${domain}
            file: ${pkgs.writeText "${domain}.zone" (toString zone)}
            zonefile-sync: -1
            zonefile-load: difference-no-serial
            journal-content: all
        '') cfg.zones)}
      '';
    };
  };
}
