{ config, lib, ... }: with lib;
let
  cfg = config.profiles.sound;
in
{
  options = {
    profiles.sound = {
      enable = mkEnableOption "the sound profile";
    };
  };

  config = mkIf cfg.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
  };
}
