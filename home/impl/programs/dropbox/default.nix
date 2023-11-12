# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, pkgsX, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  home.packages = with pkgs;
    [ maestral ]
    ++ lib.optionals machineConfig.profiles.gui.enable [ maestral-gui ];

  sops.secrets."programs/dropbox/maestral.ini" = {
    sources = [{ file = ./maestral.sops.ini; }];
  };

  home.activation."dropboxConfig" =
    let
      format = pkgs.formats.ini { };
      configFile = format.generate "maestral.ini" {
        auth = {
          keyring = "automatic";
        };
        app = {
          notification_level = 15;
          log_level = 20;
          update_notification_interval = 604800;
          bandwidth_limit_up = 0.0;
          bandwidth_limit_down = 0.0;
          max_parallel_uploads = 6;
          max_parallel_downloads = 6;
        };
        sync = {
          path = "${config.home.homeDirectory}/p/dropbox";
          reindex_interval = 604800;
          maximum_cpu_percent = 10.0;
          keep_history = 604800;
          upload = "True";
          download = "True";
        };
      };
    in
    hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" config.sops.activationPhases.${config.sops.secrets."programs/dropbox/maestral.ini".activationPhase}.activationScriptsKey ] ''
      $DRY_RUN_CMD mkdir -m 700 -p ${config.xdg.configHome}/maestral
      $DRY_RUN_CMD ${pkgsX.configobj-merge}/bin/configobj-merge ${config.xdg.configHome}/maestral/maestral.ini ${configFile} ${config.sops.secrets."programs/dropbox/maestral.ini".target}
    '';

  systemd.user.services."maestral" = {
    Unit = {
      Description = "Maestral";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };

    Service = {
      Type = "notify";
      NotifyAccess = "exec";
      ExecStart = "${pkgs.maestral}/bin/maestral start -f";
      ExecStop = "${pkgs.maestral}/bin/maestral stop";
      Restart = "on-failure";
      WatchdogSec = "30s";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };
}
