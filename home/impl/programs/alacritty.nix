# SPDX-FileCopyrightText: 2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = config.profiles.theme.font.codeFont;
    };
  };
}
