# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib;
let
  cfg = config.profiles.gui;
in
{
  options = {
    # libc versions can be incompatible, but luckily we have the exact machine
    # configuration for OpenGL so we can set up matching versions here.
    profiles.gui.opengl.packages = mkOption {
      type = types.listOf types.package;
      default = builtins.filter (p: p != null) (
        [ machineConfig.hardware.opengl.package machineConfig.hardware.opengl.package32 ] ++
        (machineConfig.hardware.opengl.extraPackages or [ ]) ++
        (machineConfig.hardware.opengl.extraPackages32 or [ ])
      );
      example = literalExpression "[ ]";
      description = ''
        The OpenGL packages to install for this system. These should override
        what may be exposed in, e.g., /run/opengl-driver.
      '';
    };
  };

  config =
    let
      # Graft libc from our package set, but otherwise use the system-wide
      # derivation.
      openGLPackages = map
        (pkg:
          let
            inherit (pkg) drvAttrs;
            stdenv = if builtins.elem pkg.system systems.doubles.i686 then pkgs.pkgsi686Linux.stdenv else pkgs.stdenv;
            drvAttrs' = drvAttrs // (builtins.intersectAttrs drvAttrs { inherit stdenv; });
          in
          (builtins.derivation drvAttrs').${pkg.outputName})
        cfg.opengl.packages;
    in
    mkIf machineConfig.profiles.gui.enable {
      home.sessionVariablesExtra = ''
        export LIBGL_DRIVERS_PATH=${makeSearchPathOutput "drivers" "lib/dri" openGLPackages}:${makeSearchPathOutput "lib" "lib/dri" openGLPackages}''${LIBGL_DRIVERS_PATH:+:''${LIBGL_DRIVERS_PATH}}
        export LIBVA_DRIVERS_PATH=${makeSearchPathOutput "drivers" "lib/dri" openGLPackages}:${makeSearchPathOutput "lib" "lib/dri" openGLPackages}''${LIBVA_DRIVERS_PATH:+:''${LIBVA_DRIVERS_PATH}}
        export XDG_DATA_DIRS=${makeSearchPathOutput "xdg" "share" openGLPackages}''${XDG_DATA_DIRS:+:''${XDG_DATA_DIRS}}
        export LD_LIBRARY_PATH=${makeLibraryPath openGLPackages}:${makeSearchPathOutput "lib" "lib/vdpau" openGLPackages}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}
      '';

      # Set up X Session (window manager program will configure).
      xsession = {
        enable = true;
        importedVariables = [
          "LIBGL_DRIVERS_PATH"
          "LIBVA_DRIVERS_PATH"
          "LD_LIBRARY_PATH"
          "XDG_SEAT"
          "XDG_SESSION_CLASS"
          "XDG_SESSION_TYPE"
          "XDG_VTNR"
        ];
      };

      nixpkgs.overlays = [
        (
          self: super:
            let
              buildFHSUserEnv' = { buildFHSUserEnv, lib }: args@{ profile ? "", ... }: buildFHSUserEnv (args // {
                profile = profile + ''
                  # Reset XDG_DATA_DIRS and LD_LIBRARY_PATH to the correct values for our user
                  export XDG_DATA_DIRS=${lib.makeSearchPathOutput "xdg" "share" openGLPackages}''${XDG_DATA_DIRS:+:''${XDG_DATA_DIRS}}
                  export LD_LIBRARY_PATH=${lib.makeLibraryPath openGLPackages}:${lib.makeSearchPathOutput "lib" "lib/vdpau" openGLPackages}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}
                '';
              });
            in
            {
              buildFHSUserEnv = self.callPackage buildFHSUserEnv' { inherit (super) buildFHSUserEnv; };
              buildFHSUserEnvBubblewrap = self.callPackage buildFHSUserEnv' { buildFHSUserEnv = super.buildFHSUserEnvBubblewrap; };
            }
        )
      ];
    };
}
