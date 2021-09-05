# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.kitty = {
    enable = true;
    settings = {
      window_padding_width = "5";
    };
  };
}
