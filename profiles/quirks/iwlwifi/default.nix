# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ... }: with lib; {
  # https://bugzilla.kernel.org/show_bug.cgi?id=203709
  boot.extraModulePackages = mkIf config.profiles.wireless.enable [
    (config.boot.kernelPackages.callPackage ./module.nix { })
  ];
}
