# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  services.dropbox = {
    enable = true;
    path = "${config.home.homeDirectory}/p/dropbox";
  };
}
