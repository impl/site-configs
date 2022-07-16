# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  # Set up X Session (window manager program will configure).
  xsession = {
    enable = true;
    scriptPath = ".xsession-hm";
  };

  # Some services require the window manager to support EWMH and check for this
  # at activation time, so this service will poll for EWMH support.
  systemd.user.services.ewmh = {
    Unit = {
      Description = "Report when the window manager supports EWMH";
      PartOf = [ "graphical-session-pre.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session-pre.target" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.wmctrl}/bin/wmctrl -l";
      Restart = "on-failure";
      StandardOutput = "null";
    };
  };

  # libc versions can be incompatible, but luckily we have the exact machine
  # configuration for OpenGL so we can set up matching versions here.
  home.sessionVariablesExtra = let
    openGLPkgs = (machineConfig.hardware.opengl.extraPackages or []) ++ (machineConfig.hardware.opengl.extraPackages32 or []);
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
