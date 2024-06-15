# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, pkgsDir, ... }:
{
  mkHomeConfigurations = homes: cfgs:
    let
      mkHomeConfigurationsForMachine = hostName: cfg:
        let
          class = cfg.class;
          machineConfig = cfg.config;
          machineHasUser = userName: cfg: builtins.hasAttr userName machineConfig.users.users;
          system = if cfg.options.nixpkgs.hostPlatform.isDefined then machineConfig.nixpkgs.hostPlatform.system else machineConfig.nixpkgs.system;

          mkHomeConfiguration = userName: cfg:
            let
              userConfig = machineConfig.users.users.${userName};

              homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration rec {
                pkgs = inputs.nixpkgs.legacyPackages.${system};
                extraSpecialArgs = {
                  inherit class machineConfig;
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
                      username = userConfig.name;
                      homeDirectory = userConfig.home;
                    };
                  }
                ];
              };
            in
              lib.nameValuePair "${userConfig.name}@${hostName}" homeConfiguration;
        in
          lib.mapAttrs' mkHomeConfiguration (lib.filterAttrs machineHasUser homes);

      homeConfigurations = builtins.mapAttrs mkHomeConfigurationsForMachine cfgs;
    in
      lib.foldAttrs (n: a: n // a) {} (builtins.attrValues homeConfigurations);
}
