# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, ... }:
let
  currentKeyIdentifier = "2026012101";
  currentKey = "unseal.${currentKeyIdentifier}.key";
in {
  sops.secrets."services/openbao/settings/seal/static/currentKey" = {
    sources = [{ file = ./unseal.${currentKeyIdentifier}.sops.key; }];
  };

  services.openbao = {
    enable = true;
    settings = {
      ui = true;

      cluster_addr = "https://${config.networking.hostName}.it.sunshine.internal:8201";
      api_addr = "https://${config.networking.hostName}.it.sunshine.internal:8200";

      listener.default = {
        type = "tcp";
        address = "[::]:8200";
      };

      seal.static = {
        current_key_id = currentKeyIdentifier;
        current_key = "file:///run/credentials/openbao.service/${currentKey}";
      };

      storage.raft = {
        path = "/var/lib/openbao";
        node_id = config.networking.hostName;
      };
    };
  };

  systemd.services.openbao = {
    serviceConfig.LoadCredential =
      "${currentKey}:${config.sops.secrets."services/openbao/settings/seal/static/currentKey".target}";
  };
}
