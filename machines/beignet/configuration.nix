{ config, lib, pkgs, ... }:
let
  mkUser = { name, extraConfig ? {} }: {
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
in lib.mkMerge [
  {
    sops.ageKeySecretSource = {
      file = ./config.sops.yaml;
      key = ''["config"]["sops"]["ageKey"]'';
    };

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
      sources = [ { file = ./keyfile.root.sops; } ];
    };
    boot.initrd.luks.devices."root" = {
      preLVM = true;
      keyFile = "/keyfile.root";
    };

    boot.plymouth.enable = true;

    fileSystems = lib.genAttrs [ "/" "/home" "/nix" "/snapshots" ] (fileSystem: {
      options = [ "compress=zstd" ];
    });

    swapDevices = [
      { device = "/swap/0"; }
    ];

    time.timeZone = "America/Los_Angeles";

    networking.interfaces.eno1.useDHCP = true;
    networking.interfaces.wlp2s0.useDHCP = true;

    # Enable profiles for this configuration.
    profiles = {
      hardware.cpu.intel.enable = true;
      hardware.gpu.intel.enable = true;
      locations.home.enable = true;
      desktop.enable = true;
      wireless = {
        enable = true;
        interfaces = [ "wlp2s0" ];
      };
    };

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.extraConfig = ''
      StreamLocalBindUnlink yes
    '';

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = false;

    nix.allowedUsers = [ "@wheel" ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.05"; # Did you read the comment?
  }
  (mkUser {
    name = "root";
  })
  (mkUser {
    name = "impl";
    extraConfig = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  })
]
