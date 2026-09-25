# SPDX-FileCopyrightText: 2023-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      Compression = true;
    };
  };
}
