# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, lib, ... }: with lib; {
  imports = optionals (class == "nixos") [
    ./amd.nix
    ./intel.nix
    ./nvidia.nix
  ];
}
