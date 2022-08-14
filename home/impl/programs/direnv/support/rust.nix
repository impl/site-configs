# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  outputs = { self, nixpkgs }: {
    devShell = with nixpkgs.lib; genAttrs systems.flakeExposed (system: with nixpkgs.legacyPackages.${system}; mkShell {
      nativeBuildInputs = [ cargo lldb rustc rustfmt clippy ];
    });
  };
}
