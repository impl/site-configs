# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.physical;
in
{
  options = {
    profiles.physical = {
      enable = mkEnableOption "the profile for physically-accessible devices";

      serial = {
        enable = mkEnableOption "access via a serial console";
        port = mkOption {
          type = types.int;
          default = 0;
          description = "The COM port to use, starting from 0.";
        };
        baud = mkOption {
          type = types.int;
          default = 115200;
          description = "The supported baud for the serial console.";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.fwupd.enable = true;
      services.pcscd.enable = true;
      services.udev.packages = [
        pkgs.libu2f-host
        pkgs.yubikey-personalization
      ];
    }
    (mkIf cfg.serial.enable {
      boot.kernelParams = [ "console=ttyS${builtins.toString cfg.serial.port},${builtins.toString cfg.serial.baud}n8" ];
      boot.loader.grub.extraConfig = ''
        serial --unit=${builtins.toString cfg.serial.port} --speed=${builtins.toString cfg.serial.baud} --word=8 --parity=no --stop=1
        terminal_input --append serial
        terminal_output --append serial
      '';
    })
  ]);
}
