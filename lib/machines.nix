# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, pkgsDir, profilesDir, ... }:
{
  mkNixosConfiguration = cfg:
    let
      compile = { modules ? [] }: lib.nixosSystem (cfg // {
        modules =
          [
            inputs.nix-sops.nixosModules.default
            profilesDir
            ({ pkgs, ... }: {
              _module.args = {
                pkgsX = pkgs.callPackage pkgsDir {};
              };
            })
          ]
          ++ (cfg.modules or [])
          ++ modules;
      });
    in lib.makeOverridable compile {};

  mkNixosConfigurations = machines:
    let
      hostNameModule = hostName: {
        networking = {
          inherit hostName;
        };
      };

      compile = hostName: cfg: self.machines.mkNixosConfiguration (cfg // {
        modules = lib.flatten [
          (cfg.modules or [])
          (hostNameModule hostName)
        ];
      });
    in builtins.mapAttrs compile machines;

  overrideNixosConfigurations = override: nixosConfigurations:
    builtins.mapAttrs (_: compiled: compiled.override override) nixosConfigurations;
}
