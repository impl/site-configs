# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
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
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      boot.initrd.kernelModules = [ "amdgpu" ];

      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.opengl.driSupport32Bit = true;
      hardware.opengl.extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime amdvlk ];
      hardware.opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    }
    (mkIf config.profiles.gui.enable {
      services.xserver = {
        videoDrivers = [ "amdgpu" ];
        deviceSection = ''Option "TearFree" "true"'';
      };
    })
  ]);
}
