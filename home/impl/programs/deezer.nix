# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgsX, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = [
    pkgsX.deezer
  ];
}
