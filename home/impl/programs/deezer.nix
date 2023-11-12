# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgsHome, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = [
    pkgsHome.deezer
  ];
}
