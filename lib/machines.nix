# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, pkgsDir, profilesDir, ... }:
{
  mkNixosConfiguration = eval: (eval inputs).extendModules {
    modules = [
      profilesDir
      ({ pkgs, ... }: {
        _module.args = {
          pkgsX = pkgs.callPackage pkgsDir {};
        };
      })
    ];
  };

  mkNixosConfigurations = machines:
    let
      compile = hostName: eval: (self.machines.mkNixosConfiguration eval).extendModules {
        modules = [
          {
            networking = {
              inherit hostName;
            };
          }
        ];
      };
    in builtins.mapAttrs compile machines;
}
