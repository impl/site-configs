# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ... }: with lib; {
  # https://bugzilla.kernel.org/show_bug.cgi?id=203709
  boot.kernelPatches = mkIf config.profiles.wireless.enable [
    {
      patch = ./iwlwifi-missed-beacons-timeout.patch;
    }
  ];
}
