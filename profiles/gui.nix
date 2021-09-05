{ config, lib, ... }: with lib;
let
  cfg = config.profiles.gui;
in
{
  options = {
    profiles.gui = {
      enable = mkEnableOption "the GUI (X11 with MATE) profile";
    };
  };

  config = mkIf cfg.enable {
    profiles = {
      userInteractive.enable = true;
    };

    services.xserver = {
      enable = true;
      layout = "us";
      desktopManager = {
        mate = {
          enable = true;
        };
        xterm = {
          enable = true;
        };
      };
    };
  };
}
