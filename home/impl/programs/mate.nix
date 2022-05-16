# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = pkgs.mate.basePackages ++
    pkgs.mate.extraPackages ++
    [
      pkgs.at-spi2-core
      pkgs.desktop-file-utils
      pkgs.glib
      pkgs.gtk3.out
      pkgs.shared-mime-info
      pkgs.xdg-user-dirs
      pkgs.yelp
    ];

  home.sessionVariables = {
    "CAJA_EXTENSION_DIRS" = "${config.home.profileDirectory}/lib/caja/extensions-2.0";
    "MATE_PANEL_APPLETS_DIR" = "${config.home.profileDirectory}/share/mate-panel/applets";
    "MATE_PANEL_EXTRA_MODULES" = "${config.home.profileDirectory}/lib/mate-panel/applets";
  };

  services.gnome-keyring.enable = true;

  gtk = {
    gtk3 = {
      # MATE themes have their own configuration for MATE applications. See,
      # e.g.,
      # https://github.com/mate-desktop/mate-themes/blob/master/desktop-themes/BlueMenta/gtk-3.0/mate-applications.css
      extraCss = ''
        MsdOsdWindow.background.osd {
          background-color: rgba(246, 245, 244, 0.6);
        }

        MsdOsdWindow.background.osd .progressbar {
          background-color: #f6f5f4;
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

  dconf.settings =
  let
    theme = config.gtk.theme.name;
    generalFont = config.gtk.font.name;
    monospaceFont = "Noto Mono";
    fontSize = config.gtk.font.size;
  in
  {
    "org/mate/desktop/session/required-components" = {
      "panel" = "";
      "windowmanager" = "mate-xsession-hm";
    };

    "org/mate/desktop/peripherals/mouse" = {
      "cursor-theme" = theme;
    };

    "org/mate/desktop/interface" = {
      "gtk-theme" = theme;
      "icon-theme" = config.gtk.iconTheme.name;
      "font-name" = "${generalFont} ${toString fontSize}";
      "document-font-name" = "${generalFont} ${toString fontSize}";
      "monospace-font-name" = "${monospaceFont} ${toString fontSize}";
    };

    "org/mate/desktop/font-rendering" = {
      "antialiasing" = "rgba";
      "hinting" = "slight";
    };

    "org/mate/desktop/sound" = {
      "theme-name" = "__no_sounds";
      "event-sounds" = false;
      "input-feedback-sounds" = false;
    };

    "org/mate/desktop/background" = {
      "picture-filename" = "${../wallpapers/zhifei-zhou-K3BTXlsXx4A-unsplash.jpg}";
      "picture-options" = "zoom";
      "show-desktop-icons" = false;
    };

    "org/mate/notification-daemon" = {
      "do-not-disturb" = false;
      "popup-location" = "bottom_right";
      "theme" = "coco";
    };
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
