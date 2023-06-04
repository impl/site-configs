# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ... }: {
  sops.ageKeySecretSource = {
    file = ./config.sops.yaml;
    key = ''["config"]["sops"]["ageKey"]'';
  };

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub = {
    enable = true;
    forcei686 = true;
    device = "/dev/sda";
  };

  fileSystems."/".device = lib.mkDefault "/dev/loop0";

  swapDevices = [
    { device = "/swap"; }
  ];

  time.timeZone = "Etc/UTC";

  networking.interfaces.ens3 = {
    ipv4 = {
      addresses = [
        {
          address = "204.109.59.50";
          prefixLength = 30;
        }
      ];
      routes = [
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "204.109.59.49";
        }
      ];
    };
    ipv6 = {
      addresses = [
        {
          address = "2607:fc50:0:d00::2";
          prefixLength = 64;
        }
      ];
      routes = [
        {
          address = "::";
          prefixLength = 0;
          via = "2607:fc50:0:d00::1";
        }
      ];
    };
  };
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844" ];

  # Enable profiles for this configuration.
  profiles = {
    locations.vpn.enable = true;
    servers.cloudflare.encryptedTunnelConfig = ./cloudflare/config.sops.yaml;
    userInteractive.enable = true;
  };

  # Enable the OpenSSH daemon.
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

  users.users.root.passwordFile = config.sops.secrets."users/users/root/hashedPassword".target;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
