# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ homeDir ? ../home
, inputs
, lib
, machinesDir ? ../machines
, profilesDir ? ../profiles
, ...
}:
let
  mkLib = self:
    let
      importLib = { file, attrs ? {} }: import file ({ inherit self inputs lib; } // attrs);
    in
    {
      homes = importLib { file = ./homes.nix; attrs = { inherit homeDir; }; };
      machines = importLib { file = ./machines.nix; attrs = { inherit machinesDir profilesDir; }; };
      mods = importLib { file = ./mods.nix; };

      inherit (self.homes) mkHomeConfigurations;
      inherit (self.machines) mkNixosConfigurations;
      inherit (self.mods) importDir;
    };
in lib.makeExtensible mkLib
