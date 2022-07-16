# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ machineConfig, ... }: self: super: {
  buildFHSUserEnv = super.callPackage ./build-fhs-userenv.nix {
    inherit machineConfig;
    inherit (super) buildFHSUserEnv;
  };
  buildFHSUserEnvBubblewrap = super.callPackage ./build-fhs-userenv.nix {
    inherit machineConfig;
    buildFHSUserEnv = super.buildFHSUserEnvBubblewrap;
  };
  makeDesktopItem = args@{ extraConfig ? {}, ... }: super.makeDesktopItem (args // { extraConfig = { "Version" = "1.0"; } // extraConfig; });
  my = import ./my.nix { pkgs = self; };
}
