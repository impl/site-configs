{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.kitty = {
    enable = true;
    settings = {
      window_padding_width = "5";
    };
  };
}
