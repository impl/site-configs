# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.cpu.amd;
in
{
  options = {
    profiles.hardware.cpu.amd = {
      enable = mkEnableOption "the AMD CPU profile";
    };
  };

  config = mkIf cfg.enable {
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;
  };
}
