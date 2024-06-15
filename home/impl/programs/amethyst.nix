# SPDX-FileCopyrightText: 2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, pkgsHome, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = optionals pkgs.stdenv.hostPlatform.isDarwin [
    pkgsHome.amethyst
  ];
}
