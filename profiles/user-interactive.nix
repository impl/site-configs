{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.userInteractive;
in
{
  options = {
    profiles.userInteractive = {
      enable = mkEnableOption "the user-interactive profile";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
      vim
    ];
  };
}
