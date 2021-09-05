{ pkgs, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  home.packages = with pkgs; [
    lsof
    reuse
    sops
  ];
}
