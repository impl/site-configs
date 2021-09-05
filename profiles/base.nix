{ pkgs, ... }:
{
  # Disable deprecated option.
  networking.useDHCP = false;

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
}
