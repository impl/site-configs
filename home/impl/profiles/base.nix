# SPDX-FileCopyrightText: 2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, lib, ... }: with lib; mkMerge [
  {
    nixpkgs = {
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-13.6.9"
        ];
      };
      overlays = [
        (import ../overlay)
      ];
    };

    programs.home-manager.enable = true;
  }
  (optionalAttrs (class == "nixos") {
    xdg.userDirs = {
      enable = true;
      createDirectories = false;
    };

    systemd.user.startServices = "sd-switch";
  })
]
