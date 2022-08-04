# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, libX, machineConfig, ... }: with lib; let
  inherit (machineConfig.profiles.hardware.display) internal;
in mkIf (machineConfig.profiles.gui.enable && internal.edid != null) {
  programs.autorandr = {
    enable = true;
    profiles."default" = {
      fingerprint = {
        "autorandr-0" = internal.edid;
      };
      config = let
        internalDesc = builtins.head (libX.edid.parseEDIDHex internal.edid).descriptors;
      in mkIf (internalDesc.type == "detailedTiming") {
        "autorandr-0" = {
          primary = true;
          position = "0x0";
          mode = "${toString internalDesc.horizontalActivePixels}x${toString internalDesc.verticalActivePixels}";
        };
      };
    };
  };
}
