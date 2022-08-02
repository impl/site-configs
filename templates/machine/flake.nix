# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  inputs = {
    site = {
      url = "github:impl/site-configs";
    };
  };

  outputs = { site, ... }: {
    nixosConfigurations = builtins.mapAttrs (_: cfg: cfg.extendModules {
      modules = [ ./configuration.nix ];
    }) site.nixosConfigurations;
  };
}
