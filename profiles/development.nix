# SPDX-FileCopyrightText: 2022-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, ... }: with lib; let
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
    boot.binfmt.emulatedSystems = lib.remove pkgs.stdenv.hostPlatform.system [
      "aarch64-linux"
      "mips64el-linux"
      "powerpc64-linux"
      "riscv64-linux"
      "x86_64-linux"
      "wasm64-wasi"
    ];

    # Enable access to serial ports for normal users in the wheel group.
    users.groups."dialout".members = mapAttrsToList
      (n: u: u.name)
      (filterAttrs
        (n: u:
          u.isNormalUser
          && builtins.elem u.name config.users.groups."wheel".members)
        config.users.users);

    # Support for running containers.
    virtualisation.podman.enable = true;
  };
}
