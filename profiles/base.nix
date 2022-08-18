# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, libX, pkgs, ... }: with lib;
{
  networking.useNetworkd = true;
  networking.useDHCP = mkOverride 500 false;
  services.resolved.enable = true;

  # Internationalization.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Nix (for Flakes support, required).
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      allowed-users = [ "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
      substituters = map (cache: cache.uri) libX.cachix.repoCacheMetadata;
      trusted-public-keys = concatMap (cache: cache.publicSigningKeys) libX.cachix.repoCacheMetadata;
    };
  };

  # Do not allow mutable users, not now, not ever.
  users.mutableUsers = false;

  # For packages that expose debugging information, include it in the path.
  environment.enableDebugInfo = true;

  # Must configure firewall for each machine.
  networking.firewall.enable = true;
}
