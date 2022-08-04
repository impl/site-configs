# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, pkgs, ... }: with lib;
{
  networking.useNetworkd = true;
  networking.useDHCP = mkOverride 500 false;

  # Internationalization.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Nix (for Flakes support, required).
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Do not allow mutable users, not now, not ever.
  users.mutableUsers = false;

  # For packages that expose debugging information, include it in the path.
  environment.enableDebugInfo = true;
}
