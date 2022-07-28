# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

self: super: {
  makeDesktopItem = args@{ extraConfig ? {}, ... }: super.makeDesktopItem (args // { extraConfig = { "Version" = "1.0"; } // extraConfig; });
}
