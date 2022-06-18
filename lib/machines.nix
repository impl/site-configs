# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, machinesDir, profilesDir, ... }:
let
  machines = self.mods.importDir machinesDir;
in
{
  mkNixosConfiguration = cfg: lib.nixosSystem (cfg // {
    modules =
      [
        inputs.nix-sops.nixosModule
        profilesDir
      ]
      ++ cfg.modules;
  });

  mkNixosConfigurations = { extraModules ? [] }:
    let
      cfgWithHostName = hostName: cfg: (cfg // {
        modules =
          cfg.modules
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
      builtins.mapAttrs (hostName: cfg: self.machines.mkNixosConfiguration (cfgWithHostName hostName cfg)) machines;
}
