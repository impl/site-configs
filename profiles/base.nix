# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, pkgs, ... }:
{
  # Disable deprecated option.
  networking.useDHCP = false;

  # Internationalization.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Nix (for Flakes support, required).
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable common cross-system build compatibility.
  boot.binfmt.emulatedSystems = lib.remove pkgs.hostPlatform.system [
    "aarch64-linux"
    "mips64el-linux"
    "powerpc64-linux"
    "riscv64-linux"
    "x86_64-linux"
    "wasm64-wasi"
  ];

  # Do not allow mutable users, not now, not ever.
  users.mutableUsers = false;
}
