{ lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  services.picom = {
    enable = true;
    inactiveDim = "0.15";
  };
}
