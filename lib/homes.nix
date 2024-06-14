# SPDX-FileCopyrightText: 2021-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, pkgsDir, ... }:
{
  mkHomeConfigurations = homes: nixosConfigurations:
    let
      mkHomeConfigurationsForNixosConfiguration = hostName: nixosConfiguration:
        let
          machineConfig = nixosConfiguration.config;
          machineHasUser = userName: cfg: builtins.hasAttr userName machineConfig.users.users;

          mkHomeConfiguration = userName: cfg:
            let
              homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration rec {
                pkgs = inputs.nixpkgs.legacyPackages.${machineConfig.nixpkgs.system};
                extraSpecialArgs = {
                  inherit machineConfig;
                  libX = self;
                  libSops = inputs.nix-sops.lib;
                  libDNS = inputs.dns.lib;
                  pkgsNUR = import inputs.nur {
                    nurpkgs = pkgs;
                    inherit pkgs;
                  };
                  pkgsX = pkgs.callPackage pkgsDir {};
                };
                modules = [
                  inputs.nix-flatpak.homeManagerModules.nix-flatpak
                  inputs.nix-sops.homeModules.default
                  cfg
                  {
                    nix.registry.nixpkgs.flake = builtins.removeAttrs inputs.nixpkgs [ "lastModifiedDate" "lastModified" ];
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
