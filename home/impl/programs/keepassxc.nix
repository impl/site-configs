# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, pkgs, machineConfig, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  home.packages = with pkgs; [
    keepassxc
  ];

  home.sessionVariables = {
    "KARP_URL" =
      if pkgs.stdenv.hostPlatform.isDarwin then ''file://''${TMPDIR%/}/org.keepassxc.KeePassXC.BrowserServer''
      else ''''${XDG_RUNTIME_DIR:-/run/user/$UID}/app/org.keepassxc.KeePassXC/org.keepassxc.KeePassXC.BrowserServer'';
  };
}
