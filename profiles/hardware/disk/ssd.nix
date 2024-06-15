# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.disk.ssd;
in
{
  _class = "nixos";

  options = {
    profiles.hardware.disk.ssd = {
      enable = mkEnableOption "the SSD disk profile";
    };
  };

  config = mkIf cfg.enable {
    services.fstrim.enable = true;
  };
}
