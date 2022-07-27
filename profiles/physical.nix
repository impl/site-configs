# SPDX-FileCopyrightText: 2021 Noah Fontes
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
    };
  };

  config = mkIf cfg.enable {
    services.fwupd.enable = true;
    services.pcscd.enable = true;
    services.udev.packages = [
      pkgs.libu2f-host
      pkgs.yubikey-personalization
    ];
  };
}
