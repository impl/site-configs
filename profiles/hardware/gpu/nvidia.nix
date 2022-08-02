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

      busID = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "PCI:1:0:0";
        description = ''
          The PCI bus ID of the Nvidia VGA controller.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.opengl.driSupport32Bit = true;
      hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau ];

      # TODO: Enable in NixOS 22.11.
      #hardware.nvidia.open = !config.hardware.nvidia.package.bin.meta.available;
      hardware.nvidia.nvidiaSettings = config.hardware.nvidia.package.settings.meta.available;
    }
    (mkIf config.profiles.gui.enable (mkMerge [
      {
        services.xserver = {
          videoDrivers = [ "nvidia" ];
        };
      }
      (mkIf (cfg.busID != null && config.profiles.hardware.gpu.intel.busID != null) {
        hardware.nvidia.prime = {
          offload.enable = true;
          nvidiaBusId = cfg.busID;
          intelBusId = config.profiles.hardware.gpu.intel.busID;
        };

        services.xserver.displayManager.setupCommands = ''
          ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
          ${pkgs.xorg.xrandr}/bin/xrandr --auto
        '';
      })
    ]))
  ]);
}
