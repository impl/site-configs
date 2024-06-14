# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  services.flatpak = {
    packages = [
      "com.valvesoftware.Steam"
    ];

    overrides."com.valvesoftware.Steam" = {
      Context = {
        filesystems = [
          "xdg-data/steam-apps:create"
        ];
      };
    };
  };
}
