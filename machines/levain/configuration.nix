# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ... }: {
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

  profiles = {
    physical = {
      enable = true;
      serial.enable = true;
    };
    userInteractive.enable = true;
  };

  services.openssh.enable = true;
  services.openssh.extraConfig = ''
    StreamLocalBindUnlink yes
  '';

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
