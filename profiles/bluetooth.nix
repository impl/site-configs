# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.bluetooth;
in
{
  _class = "nixos";

  options = {
    profiles.bluetooth = {
      enable = mkEnableOption "the profile for devices with Bluetooth interfaces";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;
      };
    }
    (mkIf config.profiles.gui.enable {
      services.blueman.enable = true;
    })
  ]);
}
