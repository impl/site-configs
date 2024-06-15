# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ pkgs, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  home.packages = with pkgs; [
    bintools
    dig
    file
    htop
    inetutils
    lsof
    moreutils
    pciutils
    reuse
    sops
    unzip
  ] ++ optionals pkgs.stdenv.hostPlatform.isLinux [
    acpi
    psmisc
    usbutils
  ];
}
