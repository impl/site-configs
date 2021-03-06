# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ pkgs, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  home.packages = with pkgs; [
    acpi
    file
    htop
    lsof
    pciutils
    psmisc
    reuse
    sops
    usbutils
  ];
}
