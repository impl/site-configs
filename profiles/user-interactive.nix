# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.userInteractive;
in
{
  options = {
    profiles.userInteractive = {
      enable = mkEnableOption "the user-interactive profile";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
      vim
    ];
  };
}
