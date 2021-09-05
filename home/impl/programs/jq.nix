{ lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.jq = {
    enable = true;
  };
}
