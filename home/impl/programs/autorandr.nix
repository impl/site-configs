# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, libX, machineConfig, pkgs, ... }: with lib; let
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

  systemd.user.services."autorandr-login" = {
    Unit = {
      Description = "autorandr";
      PartOf = [ "hm-graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "hm-graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.autorandr}/bin/autorandr --match-edid --change --force --default default";
      Restart = "on-failure";
    };
  };
  systemd.user.services."autorandr-drm-hotplug" = {
    Unit = {
      Description = "autorandr (DRM hotplug)";
      PartOf = [ "drm-hotplug.target" ];
      ReloadPropagatedFrom = [ "drm-hotplug.target" ];
    };

    Install = {
      WantedBy = [ "drm-hotplug.target" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.autorandr}/bin/autorandr --match-edid --change --default default";
      ExecReload = "${pkgs.autorandr}/bin/autorandr --match-edid --change --default default";
      Restart = "on-failure";
    };
  };
}
