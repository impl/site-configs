# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.gpu.intel;
in
  {
    options = {
      profiles.hardware.gpu.intel = {
        enable = mkEnableOption "the Intel GPU profile";
      };
    };

    config = mkIf cfg.enable (mkMerge [
      {
        hardware.opengl.enable = true;
        hardware.opengl.driSupport = true;
        hardware.opengl.driSupport32Bit = true;
        hardware.opengl.extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl intel-media-driver ];
      }
      (mkIf config.profiles.gui.enable {
        services.xserver.videoDrivers = [ "intel" ];
        services.xserver.deviceSection = ''
          Option "TearFree" "true"
        '';
      })
    ]);
  }