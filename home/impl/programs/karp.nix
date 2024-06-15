# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, pkgsHome, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = [
    (pkgsHome.karp.override {
      pinentryPackage = config.services.gpg-agent.pinentry.package;
    })
  ];
}
