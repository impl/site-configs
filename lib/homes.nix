# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, pkgsDir, ... }:
let
  baseModule = { config, lib, pkgs, ... }: {
    options.home = {
      forbiddenDependenciesRegexes = lib.mkOption {
        default = [ ];
        example = [ "-dev$" ];
        type = lib.types.listOf lib.types.str;
        description = ''
          POSIX Extended Regular Expressions that match store paths that
          should not appear in the activation package.
        '';
      };

      activationPackage = lib.mkOption {
        apply = generation:
          let
            closureInfo = pkgs.closureInfo {
              rootPaths = [ generation ];
            };
          in generation.overrideAttrs (oldAttrs: {
            buildCommand =
              oldAttrs.buildCommand
              + lib.concatStringsSep "\n" (
                map (regex: ''
                  if [[ ${regex} != "" ]]; then
                    if forbiddenPaths="$(grep -E -- "${regex}" ${closureInfo}/store-paths)"; then
                      echo -e "Activation package ${generation} contains the following disallowed paths:\n$forbiddenPaths"
                      exit 1
                    fi
                  fi
                '') config.home.forbiddenDependenciesRegexes
              );
          });
      };
    };

    config = {
      home.forbiddenDependenciesRegexes =
        map
          (output:
            "-${lib.escapeRegex pkgs.cacert-unfiltered.name}"
            + lib.optionalString (output != "out") "-${lib.escapeRegex output}"
            + "$"
          )
          pkgs.cacert-unfiltered.outputs;
    };
  };
in {
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

              homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${system};
                extraSpecialArgs = {
                  inherit class machineConfig;
                  libX = self;
                  libSops = inputs.nix-sops.lib;
                  libDNS = inputs.dns.lib;
                };
                modules = [
                  self.configs.shared
                  baseModule
                  inputs.nix-flatpak.homeManagerModules.nix-flatpak
                  inputs.nix-sops.homeModules.default
                  cfg
                  ({ config, pkgs, ... }: {
                    _module.args = {
                      pkgsNUR = import inputs.nur {
                        nurpkgs = pkgs;
                        inherit pkgs;
                      };
                      pkgsX = pkgs.callPackage pkgsDir {};
                    };
                    home = {
                      username = userConfig.name;
                      homeDirectory = userConfig.home;
                    };
                  })
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
