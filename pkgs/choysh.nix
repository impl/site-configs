# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ stdenv }:
(builtins.getFlake "github:impl/choysh?rev=e44a42f4f7fc0d3bbec66c3d436311d3eebc0759").outputs.packages.${stdenv.hostPlatform.system}.choysh
