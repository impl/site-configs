# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, ... }:
{
  imports =
    lib.optionals (builtins.pathExists ./hardware-configuration.nix) [ ./hardware-configuration.nix ];
}
