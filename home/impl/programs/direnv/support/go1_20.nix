# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  outputs = { self, nixpkgs }: {
    devShell = with nixpkgs.lib; genAttrs systems.flakeExposed (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      with pkgs; mkShell {
        nativeBuildInputs = [
          go_1_20
        ];
        shellHook = ''
          if command -v direnv >/dev/null; then
            eval "$(direnv stdlib)"
            layout go
          fi
        '';
      });
  };
}
