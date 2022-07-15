# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  inputs = {
    nixpkgs = {
      type = "path";
      path = "@nixpkgsOutPath@";
      narHash = "@nixpkgsNarHash@";
    };
  };

  outputs = { self, nixpkgs }: {
    devShell = with nixpkgs.lib; genAttrs systems.flakeExposed (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # Allow us to run ./scripts/get_maintainer.pl from anywhere in the local
      # environment.
      getMaintainer = pkgs.writeShellScript "get-maintainer.sh" ''
        set -euo pipefail

        declare noOptsLeft=
        declare -a scriptArgs

        for arg in "$@"; do
          if [[ -z "$noOptsLeft" ]]; then
            case "$arg" in
            --) noOptsLeft=1;&
            -*) scriptArgs+=("$arg"); continue;;
            esac
          fi

          scriptArgs+=("$(realpath "$arg")")
        done

        [[ -n "''${SHWD:-}" ]] && cd "$SHWD"
        exec ./scripts/get_maintainer.pl --no-git --no-git-fallback --no-rolestats "''${scriptArgs[@]}"
      '';
    in with pkgs; mkShell {
      nativeBuildInputs = [
        pkg-config
        ncurses
        flex
        bison
        openssl
        bc
        elfutils
      ];
      buildInputs = [
        linuxPackages_latest.kernel.dev
      ];
      shellHook = ''
        export GIT_CONFIG_COUNT="''${GIT_CONFIG_COUNT:-0}"

        addToGitConfig() {
          export "GIT_CONFIG_KEY_$GIT_CONFIG_COUNT"="$1"
          export "GIT_CONFIG_VALUE_$GIT_CONFIG_COUNT"="$2"
          (( GIT_CONFIG_COUNT++ ))
        }

        addToGitConfig sendemail.tocmd "SHWD=$(printf "%q" "$PWD") ${getMaintainer} --no-l --"
        addToGitConfig sendemail.cccmd "SHWD=$(printf "%q" "$PWD") ${getMaintainer} --no-m --no-r --"

        addToGitConfig sendemail.test.tocmd :
        addToGitConfig sendemail.test.cccmd :
      '';
    });
  };
}
