# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

self: super: super.lib.composeManyExtensions [
  (import ./make-desktopitem.nix)
  (import ./mate.nix)
] self super
