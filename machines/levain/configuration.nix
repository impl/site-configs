# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: {
  sops.ageKeySecretSource = {
    file = ./config.sops.yaml;
    key = ''["config"]["sops"]["ageKey"]'';
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/ata-YMTC_JGS_2201060100871";
  };

  fileSystems."/".device = lib.mkDefault "/dev/loop0";

  swapDevices = [
    { device = "/swap"; }
  ];

  time.timeZone = "Etc/UTC";

  networking.interfaces.enp1s0.useDHCP = true;

  profiles = {
    hardware.cpu.amd.enable = true;
    physical = {
      enable = true;
      serial.enable = true;
    };
    userInteractive.enable = true;
  };

  services.openssh = {
    enable = true;
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  sops.secrets."services/freeradius/configDir/mods-config/files/authorize" = {
    sources = [{ file = ./raddb/mods-config/files/authorize.sops; }];
    owner = "radius";
  };

  sops.secrets."services/freeradius/configDir/clients.conf" = {
    sources = [{ file = ./raddb/clients.sops.conf; }];
    owner = "radius";
  };

  users.users.radius.extraGroups = [ "keys" ];

  services.freeradius =
    let
      mods = [ "always" "attr_filter" "chap" "expiration" "logintime" "mschap" "pap" ];
      sites = [ "default" "inner-tunnel" ];

      raddbDir = pkgs.linkFarm "raddb" (
        [
          { name = "radiusd.conf"; path = pkgs.replaceVars ./raddb/radiusd.conf { prefix = config.services.freeradius.package; }; }
          { name = "certs/realms"; path = pkgs.emptyDirectory; }
          { name = "clients.conf"; path = config.sops.secrets."services/freeradius/configDir/clients.conf".target; }
          { name = "mods-enabled/eap"; path = ./raddb/mods-available/eap; }
          { name = "mods-enabled/files"; path = ./raddb/mods-available/files; }
        ] ++
        (map (mod: { name = "mods-enabled/${mod}"; path = "${config.services.freeradius.package}/etc/raddb/mods-available/${mod}"; }) mods) ++
        [
          { name = "mods-config/attr_filter"; path = "${config.services.freeradius.package}/etc/raddb/mods-config/attr_filter"; }
          { name = "mods-config/files/authorize"; path = config.sops.secrets."services/freeradius/configDir/mods-config/files/authorize".target; }
        ] ++
        (map (site: { name = "sites-enabled/${site}"; path = ./raddb/sites-available/${site}; }) sites) ++
        [
          { name = "policy.d"; path = "${config.services.freeradius.package}/etc/raddb/policy.d"; }
        ]
      );
    in {
      enable = true;
      configDir = raddbDir;
    };

  networking.firewall.allowedUDPPortRanges = [{ from = 1812; to = 1813; }];

  sops.secrets."users/users/root/hashedPassword" = {
    sources = [
      {
        file = ./config.sops.yaml;
        key = ''["config"]["users"]["users"]["root"]["hashedPassword"]'';
      }
    ];
  };

  users.users.root.hashedPasswordFile = config.sops.secrets."users/users/root/hashedPassword".target;

  system.stateVersion = "25.11";
}
