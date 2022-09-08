# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ pkgs, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  home.packages = with pkgs; [
    acpi
    bintools
    dig
    file
    htop
    inetutils
    lsof
    pciutils
    psmisc
    reuse
    sops
    unzip
    usbutils
  ];
}
