# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.servers.cloudflare;
in
{
  _class = "nixos";

  options = {
    profiles.servers.cloudflare = {
      encryptedTunnelConfig = mkOption {
        type = types.nullOr types.path;
        description = ''
          The path to the encrypted configuration file to use for the tunnel.
        '';
        default = null;
      };
    };
  };

  config = mkIf (cfg.encryptedTunnelConfig != null) {
    sops.secrets."profiles/servers/cloudflare/config.yaml" = {
      sources = [
        { file = cfg.encryptedTunnelConfig; }
      ];
    };

    systemd.services."cloudflared" = {
      description = "Cloudflare Tunnel";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate --config ''${CREDENTIALS_DIRECTORY}/config.yaml run'';
        DynamicUser = true;
        LoadCredential = "config.yaml:${config.sops.secrets."profiles/servers/cloudflare/config.yaml".target}";
        Restart = "on-failure";
        RestartSec = "2s";
        LimitNPROC = 512;
        LimitNOFILE = 1048576;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
      };
    };
  };
}
