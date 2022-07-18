# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ bubblewrap, lib, runCommandLocal, writeShellScriptBin }:
{ name, meta ? {}, passthru ? {}, bwrapArgs, runScript, extraAttrs ? {}, extraInstallCommands ? "" }:
let
  wrapper = writeShellScriptBin "${name}-wrapper"
    ''
      args=(
        ${lib.concatStringsSep "\n  " bwrapArgs}
        ${runScript}
      )
      exec -a "$0" ${bubblewrap}/bin/bwrap "''${args[@]}" "$@"
    '';
in runCommandLocal name { inherit meta passthru; }
  ''
    mkdir -p $out/bin
    ln -s ${wrapper}/bin/${name}-wrapper $out/bin/${name}
    ${extraInstallCommands}
  ''
