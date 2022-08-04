# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, libX, machineConfig, ... }: with lib; let
  inherit (machineConfig.profiles.hardware.display) internal;
  deskEDID =
    "00ffffffffffff005a63342012010101061c0103803c22782e6665a9544c9d26" +
    "105054bfef80e1c0d1c0b300a940a9c08180810081c0565e00a0a0a029503020" +
    "350055502100001a000000ff005559353138303630303235300a000000fd0032" +
    "4b185a19000a202020202020000000fc0056503237363820536572696573018b" +
    "020321f14e90050403020f12131e1f2021220123097f078301000065030c0020" +
    "00023a801871382d40582c450055502100001e011d8018711c1620582c250055" +
    "502100009e011d007251d01e206e28550055502100001e8c0ad08a20e02d1010" +
    "3e9600555021000018023a80d072382d40102c458055502100001e000000000c";
in mkIf (machineConfig.profiles.gui.enable && internal.edid != null) {
  programs.autorandr = {
    profiles."home:desk" = {
      fingerprint = {
        "autorandr-0" = internal.edid;
        "autorandr-1" = deskEDID;
      };
      config = let
        internalDesc = builtins.head (libX.edid.parseEDIDHex internal.edid).descriptors;
        deskDesc = builtins.head (libX.edid.parseEDIDHex deskEDID).descriptors;
      in mkIf (internalDesc.type == "detailedTiming" && deskDesc.type == "detailedTiming") {
        "autorandr-0" = {
          primary = true;
          position = "${toString deskDesc.horizontalActivePixels}x0";
          mode = "${toString internalDesc.horizontalActivePixels}x${toString internalDesc.verticalActivePixels}";
        };
        "autorandr-1" = {
          position = "0x0";
          mode = "${toString deskDesc.horizontalActivePixels}x${toString deskDesc.verticalActivePixels}";
        };
      };
    };
  };
}
