# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, pkgsHome, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  sops.secrets."programs/keepass/KeePass.config.enforced.xml" = {
    sources = [
      { file = ./KeePass.config.enforced.sops.xml; }
    ];
  };

  home.packages = let
    keepass' = pkgs.keepass.override { plugins = [ pkgs.keepass-keepassrpc ]; };
    keepass = keepass'.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        ln -s ${config.sops.secrets."programs/keepass/KeePass.config.enforced.xml".target} $out/lib/dotnet/keepass/KeePass.config.enforced.xml
      '';
    });
  in [
    keepass
    (pkgsHome.karp.override { pinentryFlavor = config.services.gpg-agent.pinentryFlavor; })
  ];
}
