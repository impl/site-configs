# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  imports = [
    ./hardware/cpu
    ./hardware/disk
    ./hardware/gpu
    ./hardware/display.nix
    ./hardware/power.nix
    ./locations/home
    ./base.nix
    ./desktop.nix
    ./development.nix
    ./physical.nix
    ./gui.nix
    ./mdns.nix
    ./printing.nix
    ./sound.nix
    ./user-interactive.nix
    ./wireless.nix
  ];
}
