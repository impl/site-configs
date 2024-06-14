# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, pkgsHome, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  sops.secrets."programs/keepass/KeePass.config.enforced.xml" = {
    sources = [
      { file = ./KeePass.config.enforced.sops.xml; }
    ];
  };

  home.packages =
    let
      pkgsKeepass = import (builtins.getFlake "github:impl/nixpkgs?rev=0edeb84346e26048f2182ca0c4d962eb2325e9a5") {
        inherit (pkgs) system;
      };

      keepass' = pkgs.keepass.override { plugins = [ pkgsKeepass.keepass-keepassrpc ]; };
      keepass = keepass'.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          ln -s ${config.sops.secrets."programs/keepass/KeePass.config.enforced.xml".target} $out/lib/dotnet/keepass/KeePass.config.enforced.xml
        '';
      });
    in
    [
      keepass
      (pkgsHome.karp.override { inherit (config.services.gpg-agent) pinentryPackage; })
    ];
}
