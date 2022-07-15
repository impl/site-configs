# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, pkgs, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = with pkgs; [
    (keepass.override { plugins = [ keepass-keepassrpc ]; })
    my.karp
  ];
}
