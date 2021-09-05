# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  services.picom = {
    enable = true;
    inactiveDim = "0.15";
  };
}
