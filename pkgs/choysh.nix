# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ stdenv }:
(builtins.getFlake "github:impl/choysh?rev=99e05b71111be54f3b36c2bcc6a270828b2241d9").outputs.packages.${stdenv.hostPlatform.system}.choysh
