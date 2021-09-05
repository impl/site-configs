{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
  };
}
