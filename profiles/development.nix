# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ... }: with lib; let
  cfg = config.profiles.development;
in
{
  options = {
    profiles.development = {
      enable = mkEnableOption "the development profile";
    };
  };

  config = mkIf cfg.enable {
    # Enable common cross-system build compatibility.
    boot.binfmt.emulatedSystems = lib.remove pkgs.hostPlatform.system [
      "aarch64-linux"
      "mips64el-linux"
      "powerpc64-linux"
      "riscv64-linux"
      "x86_64-linux"
      "wasm64-wasi"
    ];
  };
}
