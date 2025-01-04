# SPDX-FileCopyrightText: 2021-2025 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgsUnstable, ... }: with lib;
let
  cfg = config.profiles.hardware.gpu.intel;
in
{
  options = {
    profiles.hardware.gpu.intel = {
      enable = mkEnableOption "the Intel GPU profile";

      busID = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "PCI:0:2:0";
        description = ''
          The PCI bus ID of the Intel VGA controller for use with PRIME
          offloading.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgsUnstable; [ vaapiIntel vaapiVdpau libvdpau-va-gl intel-media-driver ];
      };
    }
    (mkIf config.profiles.gui.enable {
      services.xserver = mkIf (!config.profiles.hardware.gpu.nvidia.enable) {
        videoDrivers = [ "intel" ];
        deviceSection = ''
          Option "TearFree" "true"
        '';
      };
    })
  ]);
}
