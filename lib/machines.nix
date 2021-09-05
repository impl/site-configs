# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, machinesDir, profilesDir, ... }:
let
  machines = self.mods.importDir machinesDir;
in
{
  mkNixosConfigurations = { extraModules ? [] }:
    let
      mkNixosConfiguration = hostName: cfg: lib.nixosSystem (cfg // {
        modules =
          [
            inputs.nix-sops.nixosModule
            profilesDir
          ]
          ++ cfg.modules
          ++ extraModules
          ++ [
            {
              networking = {
                inherit hostName;
              };
            }
          ];
      });
    in
      builtins.mapAttrs mkNixosConfiguration machines;
}
