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
    servers.cloudflare = {
      encryptedTunnelConfig = ./cloudflare/config.sops.yaml;
    };
    servers.postgresql = {
      enable = true;
      settings = {
        max_connections = 20;
        shared_buffers = "64MB";
        effective_cache_size = "192MB";
        maintenance_work_mem = "16MB";
        checkpoint_completion_target = 0.9;
        wal_buffers = "1966kB";
        default_statistics_target = 100;
        random_page_cost = 4;
        effective_io_concurrency = 2;
        work_mem = "1638kB";
        min_wal_size = "2GB";
        max_wal_size = "8GB";
      };
    };
    servers.quassel = {
      enable = true;
    };
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

  users.users.root.hashedPasswordFile = config.sops.secrets."users/users/root/hashedPassword".target;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
