# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = with pkgs; [
    # For customizing MATE.
    dconf
    gnome.adwaita-icon-theme
    papirus-icon-theme

    # Install common fonts.
    fira-mono
    fira-code
    opensans-ttf
    roboto
    roboto-mono
    roboto-slab
    noto-fonts
    noto-fonts-emoji
    material-design-icons
    material-icons
  ];

  # Set up fontconfig to resolve our fonts.
  fonts.fontconfig.enable = true;

  # Set up X Session (window manager program will configure).
  xsession = {
    enable = true;
    scriptPath = ".xsession-hm";
    pointerCursor = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 16;
    };
  };

  # Use X Session when starting MATE.
  xdg.desktopEntries = {
    "xsession-hm" = {
      type = "Application";
      name = "X Session (Home Manager)";
      exec = "${config.home.homeDirectory}/${config.xsession.scriptPath}";
      settings = {
        "NoDisplay" = "true";
        "X-MATE-WMName" = "X Session";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
    };
    iconTheme = {
      name = "Papirus-Light";
    };
    font = {
      name = "Noto Sans";
      size = 10;
    };
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

  dconf.settings =
  let
    theme = "Adwaita";
    generalFont = "Noto Sans";
    monospaceFont = "Noto Mono";
    fontSize = 10;
  in
  {
    "org/mate/desktop/session/required-components" = {
      "panel" = "";
      "windowmanager" = "xsession-hm";
    };

    "org/mate/desktop/peripherals/mouse" = {
      "cursor-theme" = theme;
    };

    "org/mate/desktop/interface" = {
      "gtk-theme" = theme;
      "icon-theme" = "Papirus-Light";
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
}
