# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ buildFHSUserEnv, lib, machineConfig }: args@{ profile ? "", ... }:
let
  openGLPkgs = (machineConfig.hardware.opengl.extraPackages or []) ++ (machineConfig.hardware.opengl.extraPackages32 or []);
in buildFHSUserEnv (args // {
  profile = profile + ''
    # Reset XDG_DATA_DIRS and LD_LIBRARY_PATH to the correct values for our user
    export XDG_DATA_DIRS=${lib.makeSearchPathOutput "xdg" "share" openGLPkgs}''${XDG_DATA_DIRS:+:''${XDG_DATA_DIRS}}
    export LD_LIBRARY_PATH=${lib.makeLibraryPath openGLPkgs}:${lib.makeSearchPathOutput "lib" "lib/vdpau" openGLPkgs}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}
  '';
})
