# SPDX-FileCopyrightText: 2021-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  imports = [
    ./hardware/cpu
    ./hardware/disk
    ./hardware/gpu
    ./hardware/peripherals
    ./hardware/virtual
    ./hardware/display.nix
    ./hardware/power.nix
    ./locations/away
    ./locations/home
    ./locations/vpn
    ./quirks
    ./servers/authoritative-dns.nix
    ./servers/cloudflare.nix
    ./servers/postgresql.nix
    ./servers/quassel.nix
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
