# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ inputs
, lib
, overlaysDir ? ../overlays
, pkgsDir ? ../pkgs
, profilesDir ? ../profiles
, shallowRemapsDir ? ../shallow-remaps
, ...
}:
let
  mkLib = self:
    let
      importLib = { file, attrs ? { } }: import file ({ inherit self inputs lib; } // attrs);
    in
    {
      cachix = importLib { file = ./cachix.nix; };
      colors = importLib { file = ./colors.nix; };
      configs = importLib { file = ./configs.nix; attrs = { inherit overlaysDir shallowRemapsDir; }; };
      edid = importLib { file = ./edid.nix; };
      encoding = importLib { file = ./encoding.nix; };
      homes = importLib { file = ./homes.nix; attrs = { inherit pkgsDir; }; };
      machines = importLib { file = ./machines.nix; attrs = { inherit pkgsDir profilesDir; }; };
      math = importLib { file = ./math.nix; };
      mods = importLib { file = ./mods.nix; };

      inherit (self.homes) mkHomeConfigurations;
      inherit (self.machines) mkMachine mkMachineConfigurations mkMachineOutputs;
      inherit (self.mods) importDir;
    };
in
lib.makeExtensible mkLib
