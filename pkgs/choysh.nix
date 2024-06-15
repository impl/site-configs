# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ stdenv }:
(builtins.getFlake "github:impl/choysh?rev=50a7fdfd8e43dbba578ab1ae9c60bb267f33de1f").outputs.packages.${stdenv.hostPlatform.system}.choysh
