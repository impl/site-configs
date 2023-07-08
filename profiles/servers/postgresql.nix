# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib; let
  cfg = config.profiles.servers.postgresql;
in
{
  options = {
    profiles.servers.postgresql = {
      enable = mkEnableOption "the PostgreSQL server profile";

      settings = mkOption {
        type = types.attrs;
        default = {};
        description = "Additional settings for the server.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      inherit (cfg) enable settings;
      package = pkgs.postgresql_15;
    };
  };
}
