# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ... }: with lib; let
  cfg = config.profiles.desktop;
in
{
  options = {
    profiles.desktop = {
      enable = mkEnableOption "the desktop profile";
    };
  };

  config = mkIf cfg.enable {
    profiles = {
      gui.enable = true;
      mdns.enable = true;
      physical.enable = true;
      printing.enable = true;
      sound.enable = true;
    };

    # For desktop machines, where we typically have one user with physical
    # access, we can loosen default PAM restrictions (this allows, e.g.,
    # mate-screensaver to work as intended).
    security.pam.services."other" = mkForce { unixAuth = true; };

    # We want to automatically unlock a user's default keyring if possible.
    services.gnome.gnome-keyring.enable = true;

    # Don't worry about which interface gives us network access.
    systemd.network.wait-online.anyInterface = true;

    services.upower.enable = config.powerManagement.enable;

    # Propagate udev monitor hotplug events to systemd.
    systemd.targets."drm-hotplug" = {
      description = "DRM hotplug events";
      unitConfig = {
        RefuseManualStart = true;
        StopWhenUnneeded = true;
      };
    };
    systemd.targets."drm-hotplug@" = {
      description = "DRM hotplug events for /%I";
      wants = [ "drm-hotplug.target" ];
      before = [ "drm-hotplug.target" ];
      unitConfig = {
        RefuseManualStart = true;
        StopWhenUnneeded = true;
        ReloadPropagatedFrom = [ "%i.device" ];
        PropagatesReloadTo = [ "drm-hotplug.target" ];
      };
    };
    systemd.user.targets."drm-hotplug" = {
      description = "DRM hotplug events";
      unitConfig = {
        RefuseManualStart = true;
        StopWhenUnneeded = true;
      };
    };
    systemd.user.targets."drm-hotplug@" = {
      description = "DRM hotplug events for /%I";
      wants = [ "drm-hotplug.target" ];
      before = [ "drm-hotplug.target" ];
      unitConfig = {
        RefuseManualStart = true;
        StopWhenUnneeded = true;
        ReloadPropagatedFrom = [ "%i.device" ];
        PropagatesReloadTo = [ "drm-hotplug.target" ];
      };
    };
    services.udev.extraRules = ''
      SUBSYSTEM=="drm", KERNEL=="card*", ENV{DEVTYPE}=="drm_minor", TAG+="systemd", ENV{SYSTEMD_WANTS}+="drm-hotplug@.target", ENV{SYSTEMD_USER_WANTS}+="drm-hotplug@.target"
    '';
  };
}
