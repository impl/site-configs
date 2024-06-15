# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.hardware.gpu.amd;
in
{
  _class = "nixos";

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

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [ rocmPackages.clr rocmPackages.clr.icd ];
      };
    }
    (mkIf config.profiles.gui.enable {
      # Disable panel self-refresh (PSR) because it keeps making the whole system freeze.
      boot.kernelParams = [ "amdgpu.dcdebugmask=0x10" ];

      services.xserver = mkIf (!config.profiles.hardware.gpu.nvidia.enable) {
        videoDrivers = [ "amdgpu" ];
        deviceSection = ''
          Option "TearFree" "true"
        '';
      };
    })
  ]);
}
