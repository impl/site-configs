# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, libX, machineConfig, ... }: with lib; mkIf (machineConfig.networking.hostName == "palmier") {
  profiles.theme = {
    wallpaper = {
      file = ../wallpapers/don-stouder-beABEWthrpk-unsplash.jpg;
    };
  };
}
