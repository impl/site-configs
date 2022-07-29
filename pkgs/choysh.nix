# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ stdenv }:
(builtins.getFlake "github:impl/choysh?rev=e3f54fae33146457395b515456815c74a07694bd").outputs.packages.${stdenv.hostPlatform.system}.choysh
