# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  programs.firefox.userScripts = [
    {
      matches = [
        "https://outlook.office.com/*"
      ];
      jsFile = ./owa-keepalive.js;
    }
  ];
}
