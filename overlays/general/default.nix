# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

self: super: super.lib.composeManyExtensions [
  (import ./cacert.nix)
] self super
