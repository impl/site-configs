# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
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
      profiles.base.allowUnfreePackages = with pkgs; [
        config.hardware.nvidia.package
        config.hardware.nvidia.package.persistenced
        config.hardware.nvidia.package.settings
      ];

      hardware.nvidia = {
        modesetting.enable = true;
        nvidiaSettings = config.profiles.gui.enable;
        nvidiaPersistenced = mkDefault (!config.profiles.gui.enable);
      };

      # Even if we're not using X, the NixOS configuration requires this to be
      # set.
      services.xserver.videoDrivers = [ "nvidia" ];

      # These drivers "correctly" detect DPI based on the total resolution of a
      # screen compared to the total physical size of a screen, but this never
      # makes sense unless all the physical screens are exactly the same size in a
      # Xinerama configuration. Just force the DPI to 96 like every other
      # (wrong) X video driver.
      services.xserver.extraConfig = ''
        Section "OutputClass"
          Identifier "Force 96 DPI"
          MatchDriver "nvidia-drm"
          Driver "nvidia"
          Option "UseEdidDpi" "false"
          Option "DPI" "96 x 96"
        EndSection
      '';

      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.opengl.driSupport32Bit = true;
      hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau ];
    }
    (mkIf (config.profiles.hardware.gpu.amd.enable || config.profiles.hardware.gpu.intel.enable) {
      hardware.nvidia.prime = {
        sync.enable = true;

        nvidiaBusId = mkIf (cfg.busID != null) cfg.busID;
        intelBusId = mkIf (config.profiles.hardware.gpu.intel.busID != null) config.profiles.hardware.gpu.intel.busID;
        amdgpuBusId = mkIf (config.profiles.hardware.gpu.amd.busID != null) config.profiles.hardware.gpu.amd.busID;
      };
    })
  ]);
}
