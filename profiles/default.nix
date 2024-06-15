# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, lib, ... }: with lib; {
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
    ./servers/postgresql.nix
    ./base.nix
    ./desktop.nix
    ./development.nix
    ./physical.nix
    ./gui.nix
    ./mdns.nix
    ./printing.nix
    ./sound.nix
    ./user-interactive.nix
  ] ++ optionals (class == "nixos") [
    ./servers/authoritative-dns.nix
    ./servers/cloudflare.nix
    ./servers/quassel.nix
    ./wireless.nix
  ];
}
