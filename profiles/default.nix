# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  imports = [
    ./hardware/cpu/intel.nix
    ./hardware/gpu/intel.nix
    ./locations/home
    ./base.nix
    ./desktop.nix
    ./physical.nix
    ./gui.nix
    ./mdns.nix
    ./printing.nix
    ./sound.nix
    ./user-interactive.nix
    ./wireless.nix
  ];
}
