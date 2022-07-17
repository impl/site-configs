# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ machineConfig, ... }: self: super: {
  buildFHSUserEnv = self.callPackage ./build-fhs-userenv.nix {
    inherit machineConfig;
    inherit (super) buildFHSUserEnv;
  };
  buildFHSUserEnvBubblewrap = self.callPackage ./build-fhs-userenv.nix {
    inherit machineConfig;
    buildFHSUserEnv = super.buildFHSUserEnvBubblewrap;
  };
  makeDesktopItem = args@{ extraConfig ? {}, ... }: super.makeDesktopItem (args // { extraConfig = { "Version" = "1.0"; } // extraConfig; });
}
