# SPDX-FileCopyrightText: 2017-2026 Home Manager contributors
#
# SPDX-License-Identifier: MIT

{ config, lib, pkgs, ... }:
let
  cfg = config.services.dropbox;
  baseDir = "${config.home.homeDirectory}/.dropbox-hm";
in
{
  options = {
    services.dropbox = {
      enable = lib.mkEnableOption "Dropbox daemon";
      package = lib.mkPackageOption pkgs "dropbox-cli" { };
      path = lib.mkOption {
        type = lib.types.path;
        default = "${config.home.homeDirectory}/Dropbox";
        defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/Dropbox"'';
        apply = toString; # Prevent copies to Nix store.
        description = "Where to put the Dropbox directory.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.dropbox" pkgs lib.platforms.linux)
    ];

    home.packages = [ cfg.package ];

    systemd.user.services.dropbox = {
      Unit = {
        Description = "dropbox";
        After = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        Environment = [
          "HOME=${baseDir}"
        ];

        PIDFile = "${baseDir}/.dropbox/dropbox.pid";

        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;

        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStop = "${lib.getExe cfg.package} stop";
        ExecStart =
          pkgs.writeShellScript "dropbox-start" ''
            for dir in .dropbox .dropbox-dist Dropbox; do
              ${pkgs.coreutils}/bin/mkdir $VERBOSE_ARG -p \
                ${lib.escapeShellArg baseDir}/$dir

              if [[ ! -d ${lib.escapeShellArg config.home.homeDirectory}/$dir ]]; then
                ${pkgs.coreutils}/bin/ln $VERBOSE_ARG -s \
                  ${lib.escapeShellArg baseDir}/$dir ${lib.escapeShellArg config.home.homeDirectory}/$dir
              fi
            done

            if [[ ! -d ${lib.escapeShellArg cfg.path} ]]; then
              ${pkgs.coreutils}/bin/ln $VERBOSE_ARG -s \
                ${lib.escapeShellArg baseDir}/Dropbox ${lib.escapeShellArg cfg.path}
            fi

            exec ${lib.getExe pkgs.dropbox}
          '';
      };
    };
  };
}
