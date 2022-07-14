# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.bat = {
    enable = true;
  };

  home.shellAliases = {
    cat = "${pkgs.bat}/bin/bat";
  };
}
