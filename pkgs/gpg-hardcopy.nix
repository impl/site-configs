# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ stdenv }:
(builtins.getFlake "github:impl/gpg-hardcopy?rev=b2f0af03f6529162e7b4ce5e29e0e63529577456").outputs.packages.${stdenv.hostPlatform.system}.gpg-hardcopy
