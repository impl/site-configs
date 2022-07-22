# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, homeDir, inputs, lib, ... }:
let
  homes = self.mods.importDir homeDir;
in
{
  mkHomeConfigurations = nixosConfigurations:
    let
      mkHomeConfigurationsForNixosConfiguration = hostName: nixosConfiguration:
        let
          machineConfig = nixosConfiguration.config;
          machineHasUser = userName: cfg: builtins.hasAttr userName machineConfig.users.users;

          mkHomeConfiguration = userName: cfg:
            let
              homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration {
                extraSpecialArgs = {
                  inherit inputs machineConfig;
                };
                pkgs = inputs.nixpkgs.legacyPackages.${machineConfig.nixpkgs.system};
                modules = [
                  inputs.nix-sops.homeModules.default
                  cfg
                  {
                    home = {
                      username = userName;
                      homeDirectory = machineConfig.users.users.${userName}.home;
                    };
                  }
                ];
              };
            in
              lib.nameValuePair "${userName}@${hostName}" homeConfiguration;
        in
          lib.mapAttrs' mkHomeConfiguration (lib.filterAttrs machineHasUser homes);

      homeConfigurations = builtins.mapAttrs mkHomeConfigurationsForNixosConfiguration nixosConfigurations;
    in
      lib.foldAttrs (n: a: n // a) {} (builtins.attrValues homeConfigurations);
}
