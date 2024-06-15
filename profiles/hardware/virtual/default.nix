# SPDX-FileCopyrightText: 2023-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, lib, ... }: with lib; {
  imports = optionals (class == "nixos") [
    ./vmware-guest.nix
  ];
}
