# SPDX-FileCopyrightText: 2023-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, pkgs, ... }: with lib; mkIf (config.profiles.desktop.enable) (mkMerge [
  (optionalAttrs (class == "nixos") {
    services.udev.packages = [ pkgs.ledger-udev-rules ];
  })
])
