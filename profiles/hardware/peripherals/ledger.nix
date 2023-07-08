# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib; mkIf (config.profiles.desktop.enable) {
  services.udev.packages = [ pkgs.ledger-udev-rules ];
}
