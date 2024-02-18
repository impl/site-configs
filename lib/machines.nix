# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, overlaysDir, pkgsDir, profilesDir, ... }:
{
  mkNixosConfiguration = eval:
    let
      mkBuilder = name: nixpkgs: cfg: (nixpkgs.lib.nixosSystem cfg).extendModules {
        modules = [
          {
            nixpkgs.overlays = [
              (import "${overlaysDir}/${name}")
            ];
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };
      builders = builtins.mapAttrs mkBuilder {
        "unstable" = inputs.nixpkgs;
        "23.11" = inputs.nixpkgs_2311;
      };
      build = v: builders.${v};
    in (eval build).extendModules {
      modules = [
        inputs.dwarffs.nixosModules.dwarffs
        inputs.nix-sops.nixosModules.default
        inputs.systemd-user-sleep.nixosModules.systemd-user-sleep
        profilesDir
        ({ pkgs, ... }: {
          _module.args = {
            libX = self;
            libSops = inputs.nix-sops.lib;
            libDNS = inputs.dns.lib;
            pkgsUnstable = inputs.nixpkgs.legacyPackages.${pkgs.system};
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
