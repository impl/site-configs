# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  # Set up X Session (window manager program will configure).
  xsession = {
    enable = true;
    importedVariables = [
      "XDG_SEAT"
      "XDG_SESSION_CLASS"
      "XDG_SESSION_TYPE"
      "XDG_VTNR"
    ];
  };
}
