# SPDX-FileCopyrightText: 2021-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.gpg = {
    enable = true;
    settings = {
      "no-autostart" = true;
      "trusted-key" = "0xF5B2BE1B9AAD98FE291655973665FFF79D387BAA";
    };
    scdaemonSettings = {
      "disable-ccid" = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
  };

  # Disable the GNOME keyring in GUI environments because it will override
  # GnuPG SSH support.
  dconf.settings = mkIf config.xsession.enable {
    "org/mate/desktop/session" = {
      "gnome-compat-startup" = [
        "smproxy"
      ];
    };
  };

  home.activation."gnupgInit" =
    let
      keyFiles = filesystem.listFilesRecursive ../../../keys;
    in
    hm.dag.entryBetween [ "sopsInit" ] [ "writeBoundary" ] ''
      mkdir -p ${config.programs.gpg.homedir}
      chmod 0700 ${config.programs.gpg.homedir}
      ${concatStringsSep "\n" (map (keyFile: ''
        ${config.programs.gpg.package}/bin/gpg --import ${escapeShellArg keyFile}
      '') keyFiles)}
      ${config.programs.gpg.package}/bin/gpg --update-trustdb
    '';
}
