# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, libX, pkgs, pkgsHome, ... }: with lib; {
  profiles.theme = {
    colors = with libX.colors; {
      primary = mkDefault (rgb 246 245 244);
      secondary = mkDefault (rgb 91 103 107);
      text = mkDefault (rgb 46 52 54);
      urgent = mkDefault (rgb 255 109 79);
    };

    cursor = {
      package = mkDefault pkgs.gnome.adwaita-icon-theme;
      name = mkDefault "Adwaita";
      size = 16;
    };

    font = {
      packages = with pkgs; [
        fira-mono
        fira-code
        open-sans
        roboto
        roboto-mono
        roboto-slab
        noto-fonts
        noto-fonts-emoji
      ];

      generalFont = "Noto Sans";
      monospaceFont = "Noto Mono";
      codeFont = "Fira Code";
      extraFonts = [
        "Noto Sans Symbols"
        "Noto Sans Symbols2"
        "Noto Sans Math"
      ];

      size = 10;
    };

    gtk = {
      packages = with pkgs; mkDefault [
        gnome.adwaita-icon-theme
      ];

      themeName = mkDefault "Adwaita";
    };

    icons = {
      packages = with pkgs; mkDefault [
        papirus-icon-theme
      ];

      name = mkDefault "Papirus-Light";
    };

    screensaver = {
      packages = mkDefault [
        pkgsHome.xscreensaverDesktopItems
      ];
      name = mkDefault "screensavers-xscreensaver-flyingtoasters";
      idleDelayMinutes = mkDefault 1;
    };

    wallpaper = {
      file = mkDefault ./wallpapers/zhifei-zhou-K3BTXlsXx4A-unsplash.jpg;
    };
  };
}
