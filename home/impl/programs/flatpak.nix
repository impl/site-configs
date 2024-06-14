# SPDX-FileCopyrightText: 2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  services.flatpak = {
    enable = true;
    overrides = {
      global.Context.filesystems = [
        "${builtins.storeDir}:ro"
      ];
    };
  };

  home.packages = with pkgs; [
    flatpak
  ];

  xdg.systemDirs.data = [
    "${config.xdg.dataHome}/flatpak/exports/share"
  ];
}
