# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ pkgsUnstable, ... }:
{
  imports = [
    ./amd.nix
    ./intel.nix
    ./nvidia.nix
  ];
}
