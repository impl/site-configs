# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable (mkMerge [
  (optionalAttrs (class == "nixos") {
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
  })
])
