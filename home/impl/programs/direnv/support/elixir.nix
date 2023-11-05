# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  outputs = { self, nixpkgs }: {
    devShell = with nixpkgs.lib; genAttrs systems.flakeExposed (system: with nixpkgs.legacyPackages.${system}; mkShell {
      packages = [ elixir ]
        ++ optionals stdenv.isLinux [ inotify-tools ];

      shellHook = ''
        mkdir -p .direnv/elixir/mix .direnv/elixir/hex
        export MIX_HOME=$PWD/.direnv/elixir/mix
        export HEX_HOME=$PWD/.direnv/elixir/hex
        export PATH="$PWD/.direnv/elixir/mix/bin:$PWD/.direnv/elixir/hex/bin:$PATH"
        export ERL_AFLAGS="+C multi_time_warp -kernel shell_history enabled"
      '';
    });
  };
}
