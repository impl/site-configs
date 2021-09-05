{ config, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };
}
