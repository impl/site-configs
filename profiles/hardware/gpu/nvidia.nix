# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.gpu.nvidia;
in
{
  options = {
    profiles.hardware.gpu.nvidia = {
      enable = mkEnableOption "the Nvidia GPU profile";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.opengl.driSupport32Bit = true;
      hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau ];
    }
    (mkIf config.profiles.gui.enable {
      services.xserver = {
        videoDrivers = [ "nouveau" ];
        displayManager.setupCommands = mkIf config.profiles.hardware.gpu.intel.enable ''
          ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource nouveau Intel
          ${pkgs.xorg.xrandr}/bin/xrandr --auto
        '';
      };
    })
  ]);
}
