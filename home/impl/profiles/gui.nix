# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.gui;
in {
  options = {
    # libc versions can be incompatible, but luckily we have the exact machine
    # configuration for OpenGL so we can set up matching versions here.
    profiles.gui.opengl.packages = mkOption {
      type = types.listOf types.package;
      default = builtins.filter (p: p != null) (
        [ machineConfig.hardware.opengl.package machineConfig.hardware.opengl.package32 ] ++
        (machineConfig.hardware.opengl.extraPackages or []) ++
        (machineConfig.hardware.opengl.extraPackages32 or []));
      example = literalExpression "[ ]";
      description = ''
        The OpenGL packages to install for this system. These should override
        what may be exposed in, e.g., /run/opengl-driver.
      '';
    };
  };

  config = mkIf machineConfig.profiles.gui.enable {
    # Set up X Session (window manager program will configure).
    xsession = {
      enable = true;
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

    home.sessionVariablesExtra = ''
      export LIBGL_DRIVERS_PATH=${makeSearchPathOutput "lib" "lib/dri" cfg.opengl.packages}''${LIBGL_DRIVERS_PATH:+:''${LIBGL_DRIVERS_PATH}}
      export LIBVA_DRIVERS_PATH=${makeSearchPathOutput "out" "lib/dri" cfg.opengl.packages}''${LIBVA_DRIVERS_PATH:+:''${LIBVA_DRIVERS_PATH}}
      export XDG_DATA_DIRS=${makeSearchPathOutput "xdg" "share" cfg.opengl.packages}''${XDG_DATA_DIRS:+:''${XDG_DATA_DIRS}}
      export LD_LIBRARY_PATH=${makeLibraryPath cfg.opengl.packages}:${makeSearchPathOutput "lib" "lib/vdpau" cfg.opengl.packages}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}
    '';

    xsession.importedVariables = [
      "LIBGL_DRIVERS_PATH"
      "LIBVA_DRIVERS_PATH"
      "LD_LIBRARY_PATH"
    ];

    nixpkgs.overlays = [
      (
        self: super: let
          buildFHSUserEnv' = { buildFHSUserEnv, lib }: args@{ profile ? "", ... }: buildFHSUserEnv (args // {
            profile = profile + ''
              # Reset XDG_DATA_DIRS and LD_LIBRARY_PATH to the correct values for our user
              export XDG_DATA_DIRS=${lib.makeSearchPathOutput "xdg" "share" cfg.opengl.packages}''${XDG_DATA_DIRS:+:''${XDG_DATA_DIRS}}
              export LD_LIBRARY_PATH=${lib.makeLibraryPath cfg.opengl.packages}:${lib.makeSearchPathOutput "lib" "lib/vdpau" cfg.opengl.packages}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}
            '';
          });
        in {
          buildFHSUserEnv = self.callPackage buildFHSUserEnv' { inherit (super) buildFHSUserEnv; };
          buildFHSUserEnvBubblewrap = self.callPackage buildFHSUserEnv' { buildFHSUserEnv = super.buildFHSUserEnvBubblewrap; };
        }
      )
    ];
  };
}
