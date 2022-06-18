# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
{
  # Latest kernel ensures drivers are fully up to date on new systems.
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Don't know what interfaces we'll end up installing with, so have to enable
  # this globally.
  networking.useDHCP = true;

  # Assume installer is physical and user-interactive.
  profiles = {
    physical.enable = true;
    userInteractive.enable = true;
  };

  # GnuPG is required for bootstrapping.
  programs.gnupg.agent.enable = true;

  # Additional helpful packages to have installed.
  environment.systemPackages = with pkgs; [ sops ];

  # Import all key files in this repository (but do not trust explicitly, as
  # that is up to the installation operator).
  system.activationScripts."gnupgInit" = let
    keyFiles = filesystem.listFilesRecursive ../keys;
  in stringAfter [ "specialfs" "users" ] ''
    mkdir -p /root/.gnupg
    chmod 0700 /root/.gnupg
    echo allow-loopback-pinentry >>/root/.gnupg/gpg-agent.conf
    echo pinentry-mode loopback >>/root/.gnupg/gpg.conf
    ${concatStringsSep "\n" (map (keyFile: ''
      ${config.programs.gnupg.package}/bin/gpg --import ${escapeShellArg "${keyFile}"}
    '') keyFiles)}
  '';
}
