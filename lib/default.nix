# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ inputs
, lib
, overlaysDir ? ../overlays
, pkgsDir ? ../pkgs
, profilesDir ? ../profiles
, ...
}:
let
  mkLib = self:
    let
      importLib = { file, attrs ? {} }: import file ({ inherit self inputs lib; } // attrs);
    in
    {
      cachix = importLib { file = ./cachix.nix; };
      colors = importLib { file = ./colors.nix; };
      edid = importLib { file = ./edid.nix; };
      encoding = importLib { file = ./encoding.nix; };
      homes = importLib { file = ./homes.nix; };
      machines = importLib { file = ./machines.nix; attrs = { inherit overlaysDir pkgsDir profilesDir; }; };
      math = importLib { file = ./math.nix; };
      mods = importLib { file = ./mods.nix; };

      inherit (self.homes) mkHomeConfigurations;
      inherit (self.machines) mkNixosConfiguration mkNixosConfigurations overrideNixosConfigurations;
      inherit (self.mods) importDir;
    };
in lib.makeExtensible mkLib
