# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.cpu.intel;
in
  {
    options = {
      profiles.hardware.cpu.intel = {
        enable = mkEnableOption "the Intel CPU profile";
      };
    };

    config = mkIf cfg.enable {
      hardware.enableRedistributableFirmware = true;
      hardware.cpu.intel.updateMicrocode = true;
    };
  }
