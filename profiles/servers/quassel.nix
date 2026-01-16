# SPDX-FileCopyrightText: 2023-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib; let
  cfg = config.profiles.servers.quassel;
in
{
  options = {
    profiles.servers.quassel = {
      enable = mkEnableOption "the Quassel daemon profile";
    };
  };

  config = mkIf cfg.enable {
    services.quassel = {
      enable = true;
      user = mkForce null;
      dataDir = "/var/lib/quassel";
      interfaces = [
        "0.0.0.0"
        "::"
      ];
    };

    services.postgresql = {
      ensureUsers = [
        { name = "quassel"; }
      ];
    };

    systemd.services.postgresql.postStart = mkAfter ''
      psql -tAc "select 1 from pg_database where datname = 'quassel'" | grep -q 1 \
        || psql -tAc "create database quassel owner quassel encoding 'utf8'"
    '';
  };
}
