# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, libX, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = with pkgs; mate.basePackages ++
    mate.extraPackages ++
    [
      at-spi2-core
      dconf
      desktop-file-utils
      glib
      gtk3.out
      shared-mime-info
      xdg-user-dirs
      yelp
    ];

  home.sessionVariables = {
    "CAJA_EXTENSION_DIRS" = "${config.home.profileDirectory}/lib/caja/extensions-2.0";
    "MATE_PANEL_APPLETS_DIR" = "${config.home.profileDirectory}/share/mate-panel/applets";
    "MATE_PANEL_EXTRA_MODULES" = "${config.home.profileDirectory}/lib/mate-panel/applets";
  };

  services.gnome-keyring.enable = true;

  gtk = {
    gtk3 = with config.profiles.theme.colors; with libX.colors; {
      # MATE themes have their own configuration for MATE applications. See,
      # e.g.,
      # https://github.com/mate-desktop/mate-themes/blob/master/desktop-themes/BlueMenta/gtk-3.0/mate-applications.css
      extraCss = ''
        MsdOsdWindow.background.osd {
          background-color: ${toCSS (scaleAlpha (-40) primary)};
        }

        MsdOsdWindow.background.osd .progressbar {
          background-color: ${toCSS primary};
        }
      '';
    };
  };

  xdg.desktopEntries = {
    "mate-xmonad" = {
      type = "Application";
      name = "Xmonad";
      exec = "${pkgs.systemd}/bin/systemctl --user start --wait xmonad.service";
      settings = {
        "NoDisplay" = "true";
        "X-MATE-WMName" = "Xmonad";
      };
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-xapp
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [
      pkgs.mate.mate-desktop
    ];
  };

  dconf.settings = let
    themeCfg = config.profiles.theme;
  in
  {
    "org/mate/desktop/peripherals/mouse" = {
      "cursor-theme" = themeCfg.gtk.themeName;
    };

    "org/mate/desktop/interface" = {
      "gtk-theme" = themeCfg.gtk.themeName;
      "icon-theme" = themeCfg.icons.name;
      "font-name" = "${themeCfg.font.generalFont} ${toString themeCfg.font.size}";
      "document-font-name" = "${themeCfg.font.generalFont} ${toString themeCfg.font.size}";
      "monospace-font-name" = "${themeCfg.font.monospaceFont} ${toString themeCfg.font.size}";
    };

    "org/mate/desktop/font-rendering" = {
      "antialiasing" = "rgba";
      "hinting" = "slight";
    };

    "org/mate/desktop/lockdown" = {
      "disable-user-switching" = true;
    };

    "org/mate/desktop/session" = {
      "idle-delay" = themeCfg.screensaver.idleDelayMinutes;
    };

    "org/mate/desktop/session/required-components" = {
      "panel" = "";
      "windowmanager" = "mate-xmonad";
    };

    "org/mate/desktop/sound" = {
      "theme-name" = "__no_sounds";
      "event-sounds" = false;
      "input-feedback-sounds" = false;
    };

    "org/mate/desktop/background" = mkMerge [
      {
        "show-desktop-icons" = false;
      }
      (mkIf (themeCfg.wallpaper.file != null) {
        "picture-filename" = "${themeCfg.wallpaper.file}";
        "picture-options" =
          if themeCfg.wallpaper.mode == "fit" then "zoom"
          else if themeCfg.wallpaper.mode == "tile" then "wallpaper"
          else themeCfg.wallpaper.mode;
      })
    ];

    "org/mate/notification-daemon" = {
      "do-not-disturb" = false;
      "popup-location" = "bottom_right";
      "theme" = "coco";
    };

    "org/mate/power-manager" = mkMerge [
      {
        "sleep-computer-ac" = 0;
        "button-lid-ac" = "suspend";
        "sleep-display-ac" = 1800;
        "brightness-ac" = themeCfg.power.brightnessOnAdapter;
        "idle-dim-ac" = false;

        "button-power" = "interactive";
        "button-suspend" = "suspend";
      }
      (mkIf (machineConfig.profiles.hardware.power.batteries != []) {
        "sleep-computer-battery" = 1800;
        "button-lid-battery" = "suspend";
        "action-critical-battery" = "suspend";
        "sleep-display-battery" = 600;
        "backlight-battery-reduce" = true;
        "idle-dim-battery" = false;
        "kbd-backlight-battery-reduce" = true;
      })
    ];

    "org/mate/screensaver" = mkMerge [
      {
        "idle-activation-enabled" = true;
        "lock-enabled" = true;
        "user-switch-enabled" = false;
        "mode" = mkDefault "blank-only";
      }
      (mkIf (themeCfg.screensaver.name != null) {
        "mode" = "single";
        "themes" = [
          themeCfg.screensaver.name
        ];
      })
    ];

    "org/mate/settings-daemon/plugins/xrandr" = {
      "active" = false;
    };
  };

  xsession = {
    windowManager.command = mkForce ''
      XDG_CURRENT_DESKTOP=MATE XDG_SESSION_DESKTOP=mate ${pkgs.mate.mate-session-manager}/bin/mate-session
    '';
  };
}
