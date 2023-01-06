# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }:
let
  mkUser = { name, extraConfig ? { } }: {
    sops.secrets."users/users/${name}/hashedPassword" = {
      sources = [
        {
          file = ./config.sops.yaml;
          key = ''["config"]["users"]["users"]["${name}"]["hashedPassword"]'';
        }
      ];
    };

    users.users.${name} = extraConfig // {
      passwordFile = config.sops.secrets."users/users/${name}/hashedPassword".target;
    };
  };
in
lib.mkMerge [
  {
    sops.ageKeySecretSource = {
      file = ./config.sops.yaml;
      key = ''["config"]["sops"]["ageKey"]'';
    };

    boot.kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor (pkgs.linux_latest.override {
      structuredExtraConfig = with lib.kernel; {
        # https://bugzilla.kernel.org/show_bug.cgi?id=216345
        PINCTRL_AMD = yes;
      };
    }));

    boot.supportedFilesystems = [ "btrfs" ];

    boot.loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    boot.loader.grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      device = "nodev";
      enableCryptodisk = true;
    };

    sops.bootSecrets."/keyfile.root" = {
      sources = [{ file = ./keyfile.root.sops; }];
    };
    boot.initrd.luks.devices."root" = {
      device = lib.mkDefault "/dev/loop0";
      preLVM = true;
      keyFile = "/keyfile.root";
    };

    boot.plymouth.enable = true;

    fileSystems = lib.genAttrs [ "/" "/home" "/nix" "/snapshots" ] (fileSystem: {
      device = lib.mkDefault "/dev/loop0";
      options = [ "compress=zstd" ];
    });

    swapDevices = [
      { device = "/swap/0"; }
    ];

    time.timeZone = "America/Los_Angeles";

    networking.interfaces.wlp1s0.useDHCP = true;

    # Enable profiles for this configuration.
    profiles = {
      hardware.cpu.amd.enable = true;
      hardware.disk.ssd.enable = true;
      hardware.display.internal.edid =
        "00ffffffffffff0006af9aa400000000141f0104a51e1378030025a855499f25" +
        "0e505400000001010101010101010101010101010101fa3c80b870b024401010" +
        "3e002dbc10000018a72880b870b0244010103e002dbc10000018000000000000" +
        "00000000000000000000000000000002000c2dff103cc80a081bc8202020009b";
      hardware.gpu.amd.enable = true;
      hardware.power = {
        adapter = "AC";
        batteries = [ "BAT0" ];
      };
      locations = {
        home.enable = true;
        vpn.enable = true;
      };
      desktop.enable = true;
      development.enable = true;
      wireless = {
        enable = true;
        interfaces = [ "wlp1s0" ];
      };
    };

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.extraConfig = ''
      StreamLocalBindUnlink yes
    '';

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.05"; # Did you read the comment?
  }
  (mkUser {
    name = "root";
  })
  (mkUser {
    name = "impl";
    extraConfig = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  })
]
