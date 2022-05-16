# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
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
    open-sans
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
  };

  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
    x11.enable = true;
    gtk.enable = true;
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
  };

  # libc versions can be incompatible, but luckily we have the exact machine
  # configuration for OpenGL so we can set up matching versions here.
  home.sessionVariablesExtra = let
    openGLPkgs = machineConfig.hardware.opengl.extraPackages;
  in ''
    export LIBGL_DRIVERS_PATH=${makeSearchPathOutput "lib" "lib/dri" openGLPkgs}''${LIBGL_DRIVERS_PATH:+:''${LIBGL_DRIVERS_PATH}}
    export LIBVA_DRIVERS_PATH=${makeSearchPathOutput "out" "lib/dri" openGLPkgs}''${LIBVA_DRIVERS_PATH:+:''${LIBVA_DRIVERS_PATH}}
    export LD_LIBRARY_PATH=${makeLibraryPath openGLPkgs}:${makeSearchPathOutput "lib" "lib/vdpau" openGLPkgs}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}
  '';
  xsession.importedVariables = [
    "LIBGL_DRIVERS_PATH"
    "LIBVA_DRIVERS_PATH"
    "LD_LIBRARY_PATH"
  ];
}
