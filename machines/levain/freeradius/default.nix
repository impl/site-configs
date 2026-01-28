# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, pkgs, ... }: {
  users.users.radius.extraGroups = [ "keys" ];

  sops.secrets."services/freeradius/configDir/mods-config/files_mac_addrs/authorize" = {
    sources = [{ file = ./raddb/mods-config/files_mac_addrs/authorize.sops; }];
    owner = "radius";
  };

  sops.secrets."services/freeradius/configDir/clients.conf" = {
    sources = [{ file = ./raddb/clients.sops.conf; }];
    owner = "radius";
  };

  services.freeradius =
    let
      mods = [ "always" "attr_filter" "detail" "expr" "pam" "pap" "sradutmp" "unpack" ];
      sites = [ "default" "inner-tunnel" ];

      raddbDir = pkgs.linkFarm "raddb" (
        [
          { name = "radiusd.conf"; path = pkgs.replaceVars ./raddb/radiusd.conf { prefix = config.services.freeradius.package; }; }
          { name = "certs/realms"; path = pkgs.emptyDirectory; }
          { name = "clients.conf"; path = config.sops.secrets."services/freeradius/configDir/clients.conf".target; }
          { name = "mods-enabled/eap"; path = ./raddb/mods-available/eap; }
          { name = "mods-enabled/files_mac_addrs"; path = ./raddb/mods-available/files_mac_addrs; }
        ] ++
        (map (mod: { name = "mods-enabled/${mod}"; path = "${config.services.freeradius.package}/etc/raddb/mods-available/${mod}"; }) mods) ++
        [
          { name = "mods-config/attr_filter"; path = "${config.services.freeradius.package}/etc/raddb/mods-config/attr_filter"; }
          { name = "mods-config/files_mac_addrs/authorize"; path = config.sops.secrets."services/freeradius/configDir/mods-config/files_mac_addrs/authorize".target; }
        ] ++
        (map (site: { name = "sites-enabled/${site}"; path = ./raddb/sites-available/${site}; }) sites) ++
        [
          { name = "policy.d"; path = "${config.services.freeradius.package}/etc/raddb/policy.d"; }
        ]
      );
    in {
      enable = true;
      package = pkgs.freeradius.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.linux-pam ];
      });
      configDir = raddbDir;
    };

  security.pam.services.radiusd = { };
  systemd.services.freeradius.serviceConfig.SupplementaryGroups = [ "shadow" ];

  networking.firewall.allowedUDPPortRanges = [{ from = 1812; to = 1813; }];
}
