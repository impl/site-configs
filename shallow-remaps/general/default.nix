# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

pkgs: pkgs.lib.foldl' (p: remap: p // remap p) pkgs [
  (import ./cacert.nix)
]
