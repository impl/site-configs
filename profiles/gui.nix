# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.gui;
in
{
  options = {
    profiles.gui = {
      enable = mkEnableOption "the GUI profile";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      profiles.userInteractive.enable = true;
    }
    (optionalAttrs (class == "nixos") {
      profiles.base.allowUnfreePackages = [ pkgs.steamPackages.steam ];

      hardware.steam-hardware.enable = true;

      services.xserver = {
        enable = true;
        layout = "us";
        libinput.enable = true;
        desktopManager = {
          xterm = {
            enable = true;
          };
        };
      };

      services.flatpak.enable = true;
      services.gvfs.enable = true;

      xdg.portal = {
        enable = true;
        config.common.default = "*";
      };
    })
  ]);
}
