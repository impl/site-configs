# SPDX-FileCopyrightText: 2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  home.packages = with pkgs; [
    valgrind
  ];
}
