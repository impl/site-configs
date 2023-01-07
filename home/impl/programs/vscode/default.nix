# SPDX-FileCopyrightText: 2021-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, pkgsX, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/code \
          --add-flags --force-disable-user-env
      '';
    });
    mutableExtensionsDir = false;
    extensions =
      let
        loadAfter = deps: pkg: pkg.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.jq pkgs.moreutils ];
          preInstall = (old.preInstall or "") + ''
            jq '.extensionDependencies |= . + $deps' \
              --argjson deps ${escapeShellArg (builtins.toJSON deps)} \
              package.json | sponge package.json
          '';
        });
        extensions' = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "mkhl";
            name = "direnv";
            version = "0.6.1";
            sha256 = "sha256-5/Tqpn/7byl+z2ATflgKV1+rhdqj+XMEZNbGwDmGwLQ=";
          }
        ] ++ map (loadAfter [ "mkhl.direnv" ]) (
          with pkgs.vscode-extensions; [
            _4ops.terraform
            dbaeumer.vscode-eslint
            editorconfig.editorconfig
            esbenp.prettier-vscode
            golang.go
            haskell.haskell
            jnoortheen.nix-ide
            justusadam.language-haskell
            matklad.rust-analyzer
            stkb.rewrap
            vadimcn.vscode-lldb
          ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              publisher = "GitHub";
              name = "copilot";
              version = "1.55.7117";
              sha256 = "sha256-06uTcRfT1QPI1eJyJSq0bbg8bIgaAtsmApjSMGtstYY=";
            }
            {
              publisher = "SteefH";
              name = "external-formatters";
              version = "0.2.0";
              sha256 = "sha256-zqqW5/QgVvD2EF/b/vx/kc8rD/YV38l5b4YXSFKE61M=";
            }
            {
              publisher = "betterthantomorrow";
              name = "calva";
              version = "2.0.313";
              sha256 = "sha256-UJ0aAgrW5DBV7mNZj8AFjol2hum5IdkKkp8Qtu2Kk4o=";
            }
            {
              publisher = "flowtype";
              name = "flow-for-vscode";
              version = "2.2.0";
              sha256 = "sha256-NwQvbhls0deA8hwa/dqfNW1cjDsAJb5N5PAQhQwE4VY=";
            }
            {
              publisher = "mrded";
              name = "railscasts";
              version = "0.0.4";
              sha256 = "sha256-vjfoeRW+rmYlzSuEbYJqg41r03zSfbfuNCfAhHYyjDc=";
            }
            {
              publisher = "stylelint";
              name = "vscode-stylelint";
              version = "1.2.3";
              sha256 = "sha256-zs7tVrevvWNCpOrLyGIHeIpjRweVj9GG0KpV9j5NN0w=";
            }
          ]
        );
      in
      extensions' ++ [ (pkgs.callPackage ./extensions-json.nix { drvs = extensions'; }) ];
    userSettings = {
      "[css]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[go]" = {
        "editor.snippetSuggestions" = "none";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = true;
        };
      };

      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[javascriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[nix]" = {
        "editor.tabSize" = 2;
      };

      "[postcss]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[rust]" = {
        "editor.formatOnSave" = true;
      };

      "[terragrunt]" = {
        "editor.formatOnSave" = true;
      };

      "[tf]" = {
        "editor.formatOnSave" = true;
      };

      "[tfvars]" = {
        "editor.formatOnSave" = true;
      };

      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "calva.clojureLspPath" = "${pkgs.clojure-lsp}/bin/clojure-lsp";
      "calva.showCalvaSaysOnStart" = false;

      "css.validate" = false;

      "docker.showStartPage" = false;

      "editor.fontFamily" = builtins.toJSON config.profiles.theme.font.codeFont;
      "editor.fontLigatures" = true;
      "editor.fontSize" = 14;
      "editor.minimap.enabled" = true;
      "editor.suggestSelection" = "first";
      "editor.inlineSuggest.enabled" = true;

      "extensions.autoUpdate" = false;
      "extensions.ignoreRecommendations" = true;
      "extensions.showRecommendationsOnlyOnDemand" = true;

      "explorer.autoReveal" = true;
      "explorer.confirmDragAndDrop" = false;

      "externalFormatters.languages" = {
        "terragrunt" = {
          "command" = "${pkgsX.hclfmt}/bin/hclfmt";
        };
      } // (genAttrs [ "tf" "tfvars" ] (_language: {
        "command" = "${pkgs.terraform}/bin/terraform";
        "arguments" = [ "fmt" "-" ];
      }));

      "files.autoSave" = "off";

      "flow.pathToFlow" = "${pkgs.flow}/bin/flow";
      "flow.useBundledFlow" = false;
      "flow.useNPMPackagedFlow" = false;

      "haskell.manageHLS" = "PATH";

      "javascript.suggest.autoImports" = false;

      "lldb.library" = "${pkgs.lldb.lib}/lib/liblldb.so";

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.rnix-lsp}/bin/rnix-lsp";

      "stylelint.validate" = [ "css" "postcss" ];

      "telemetry.enableTelemetry" = false;

      "typescript.suggest.autoImports" = false;

      "update.mode" = "none";

      "window.titleBarStyle" = "native";
      "window.zoomLevel" = 0;

      "workbench.colorTheme" = "RailsCasts";
      "workbench.editor.untitled.hint" = "hidden";
    };
  };
}