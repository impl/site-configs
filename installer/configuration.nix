# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, pkgsX, ... }: with lib;
{
  # Latest kernel ensures drivers are fully up to date on new systems.
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Don't know what interfaces we'll end up installing with, so have to enable
  # this globally.
  networking.useDHCP = true;

  # Assume installer is physical and user-interactive.
  profiles = {
    physical.enable = true;
    printing.enable = true;
    userInteractive.enable = true;
  };

  # GnuPG is required for bootstrapping.
  programs.gnupg.agent.enable = true;

  # Additional helpful packages to have installed.
  environment.systemPackages = with pkgs; with pkgsX; [
    gpg-hardcopy
    sops
  ];

  # Enable the serial console at 115200 baud, 8N1, which should be sufficient
  # for any modern devices.
  boot.loader.grub.extraConfig = ''
    serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
  '';

  # Import all key files in this repository (but do not trust explicitly, as
  # that is up to the installation operator); set up GnuPG with usable defaults
  # for the root user, even when working with sudo.
  system.activationScripts."gnupgInit" =
    let
      keyFiles = filesystem.listFilesRecursive ../keys;
    in
    stringAfter [ "specialfs" "users" ] ''
      mkdir -p /root/{.gnupg,.ssh}
      chmod 0700 /root/{.gnupg,.ssh}
      echo allow-loopback-pinentry >>/root/.gnupg/gpg-agent.conf
      echo enable-ssh-support >>/root/.gnupg/gpg-agent.conf
      echo pinentry-program ${pkgs.pinentry.tty}/bin/pinentry >>/root/.gnupg/gpg-agent.conf
      echo pinentry-mode loopback >>/root/.gnupg/gpg.conf
      echo 'Match host * exec "gpg-connect-agent updatestartuptty /bye"' >>/root/.ssh/config
      echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >>/root/.profile
      echo 'test -z "$PS1" -o -O $(tty) || exec script -qe /dev/null' >>/root/.profile
      ${concatStringsSep "\n" (map (keyFile: ''
        ${config.programs.gnupg.package}/bin/gpg --import ${escapeShellArg "${keyFile}"}
      '') keyFiles)}
    '';
}
