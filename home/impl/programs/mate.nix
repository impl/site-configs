# SPDX-FileCopyrightText: 2022 Noah Fontes
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

  # Delegate to Home Manager X Session when starting MATE.
  xdg.desktopEntries = {
    "mate-xsession-hm" = {
      type = "Application";
      name = "X Session (Home Manager)";
      exec = "${config.home.homeDirectory}/${config.xsession.scriptPath}";
      settings = {
        "NoDisplay" = "true";
        "X-MATE-WMName" = "X Session";
      };
    };
  };

  dconf.settings = let
    themeCfg = config.profiles.theme;
  in
  {
    "org/mate/desktop/session/required-components" = {
      "panel" = "";
      "windowmanager" = "mate-xsession-hm";
    };

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
        "picture-options" = "zoom";
      })
    ];

    "org/mate/notification-daemon" = {
      "do-not-disturb" = false;
      "popup-location" = "bottom_right";
      "theme" = "coco";
    };

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
  };

  home.file.".xsession" = {
    executable = true;
    text = ''
      if [ -z "$HM_XPROFILE_SOURCED" ]; then
        . "${config.home.homeDirectory}/${config.xsession.profilePath}"
      fi
      unset HM_XPROFILE_SOURCED

      export XDG_CURRENT_DESKTOP=MATE
      export XDG_SESSION_DESKTOP=MATE

      exec ${pkgs.mate.mate-session-manager}/bin/mate-session
    '';
  };
}
