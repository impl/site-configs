# SPDX-FileCopyrightText: 2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, pkgs, ... }: with lib; mkIf (config.profiles.desktop.enable) (mkMerge [
  (optionalAttrs (class == "nixos") {
    hardware.flipperzero.enable = true;
  })
])
