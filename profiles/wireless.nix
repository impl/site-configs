{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.profiles.wireless;
in
{
  options = {
    profiles.wireless = {
      enable = mkEnableOption "the profile for devices with Wi-Fi interfaces";

      interfaces = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "wlan0" "wlan1" ];
        description = ''
          The interfaces <command>wpa_supplicant</command> will use. If empty,
          it will automatically use all wireless interfaces.

          <note>
            <para>
              A separate <command>wpa_supplicant</command> instance will be
              started for each interface.
            </para>
          </note>
        '';
      };

      encryptedConfigs = mkOption {
        type = types.listOf types.path;
        description = ''
          A list of SOPS-encrypted files to include in the
          <command>wpa_supplicant</command> configuration.
        '';
        default = [];
      };
    };
  };

  config = mkIf cfg.enable {
    networking.wireless = {
      inherit (cfg) enable interfaces;

      # We will replace the networks with our own encrypted configurations.
      userControlled.enable = mkForce false;
      networks = mkForce {};
      extraConfig = mkForce "";
    };

    sops.secrets."etc/wpa_supplicant.conf" = {
      sources = map (f: { file = f; }) cfg.encryptedConfigs;
    };
    environment.etc."wpa_supplicant.conf" = {
      source = config.sops.secrets."etc/wpa_supplicant.conf".target;
    };
  };
}
