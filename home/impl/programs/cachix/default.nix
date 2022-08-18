# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, libX, pkgs, ... }: with lib; {
  home.packages = [
    pkgs.cachix
  ];

  nix.settings = {
    extra-substituters = map (cache: cache.uri) libX.cachix.repoCacheMetadata;
    extra-trusted-public-keys = concatMap (cache: cache.publicSigningKeys) libX.cachix.repoCacheMetadata;
  };

  sops.secrets."programs/cachix/cachix.dhall" = {
    sources = [
      { file = ./cachix.sops.dhall; }
    ];
  };

  xdg.configFile."cachix/cachix.dhall" = {
    source = config.sops.secrets."programs/cachix/cachix.dhall".target;
  };
}
