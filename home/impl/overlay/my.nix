# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ pkgs }: {
  karp = (builtins.getFlake "github:impl/karp/816e55effc066b96c4aabd110a3ee404e3c227e2").outputs.defaultPackage.${pkgs.stdenv.hostPlatform.system};
}
