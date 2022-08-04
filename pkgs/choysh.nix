# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ stdenv }:
(builtins.getFlake "github:impl/choysh?rev=154fa15240a85ed4df63aac1dd1acca69b1064d6").outputs.packages.${stdenv.hostPlatform.system}.choysh
