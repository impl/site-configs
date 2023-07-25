# SPDX-FileCopyrightText: 2021-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.gpu.amd;
in
{
  options = {
    profiles.hardware.gpu.amd = {
      enable = mkEnableOption "the AMD GPU profile";

      busID = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "PCI:99:0:0";
        description = ''
          The PCI bus ID of the AMD VGA controller for use with PRIME
          offloading.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      boot.initrd.kernelModules = [ "amdgpu" ];

      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.opengl.driSupport32Bit = true;
      hardware.opengl.extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
    }
    (mkIf config.profiles.gui.enable {
      services.xserver = mkIf (!config.profiles.hardware.gpu.nvidia.enable) {
        videoDrivers = [ "amdgpu" ];
        deviceSection = ''
          Option "TearFree" "true"
        '';
      };
    })
  ]);
}
