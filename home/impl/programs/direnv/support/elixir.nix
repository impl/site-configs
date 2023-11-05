# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  outputs = { self, nixpkgs }: {
    devShell = with nixpkgs.lib; genAttrs systems.flakeExposed (system: with nixpkgs.legacyPackages.${system}; mkShell {
      packages = [
        elixir
      ];
    });
  };
}
