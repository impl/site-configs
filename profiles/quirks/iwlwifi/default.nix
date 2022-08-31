# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  # https://bugzilla.kernel.org/show_bug.cgi?id=203709
  boot.kernelPatches = [
    {
      patch = ./iwlwifi-missed-beacons-timeout.patch;
    }
  ];
}
