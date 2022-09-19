# SPDX-FileCopyrightText: 2022 Noah Fontes
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
          go_1_19
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
