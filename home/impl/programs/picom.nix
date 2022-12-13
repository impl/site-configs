# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  services.picom = mkMerge [
    {
      # These are the actual UI settings we care about.
      enable = true;
      settings = {
        inactive-dim = 0.15;
      };
    }
    {
      # Some minor adjustments to try to prevent tearing/flickering.
      backend = "xrender";
      settings = {
        unredir-if-possible = false;
      };
    }
    {
      # This doesn't actually fade anything, but it does seem to prevent the
      # desktop background from flickering when moving between workspaces.
      fade = true;
      fadeDelta = 50;
      settings = {
        fade-in-step = 1;
        fade-out-step = 1;
      };
    }
  ];
}
