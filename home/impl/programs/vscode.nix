# SPDX-FileCopyrightText: 2021-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, pkgsX, ... }: with lib; {
  options = {
    programs.vscode = {
      direnvSensitiveExtensions = mkOption {
        type = types.listOf types.package;
        default = [ ];
        example = literalExpression "[ pkgs.vscode-extensions.bbenoist.nix ]";
        description = ''
          Extensions that should be loaded after the direnv extension.
        '';
      };
    };
  };

  config = mkIf machineConfig.profiles.gui.enable {
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
      direnvSensitiveExtensions = with pkgs.vscode-extensions; [
        _4ops.terraform
        bierner.markdown-mermaid
        bradlc.vscode-tailwindcss
        dbaeumer.vscode-eslint
        editorconfig.editorconfig
        elixir-lsp.vscode-elixir-ls
        esbenp.prettier-vscode
        golang.go
        haskell.haskell
        jnoortheen.nix-ide
        justusadam.language-haskell
        matklad.rust-analyzer
        ms-python.python
        ms-python.vscode-pylance
        phoenixframework.phoenix
        stkb.rewrap
        vadimcn.vscode-lldb
        yzhang.markdown-all-in-one
        zxh404.vscode-proto3
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "GitHub";
          name = "copilot";
          version = "1.133.531";
          sha256 = "sha256-zuQKCoAUH87KqTx4KPs5v2MDP2F1Ab0Xa7LMZKcpBHE=";
        }
        {
          publisher = "GitHub";
          name = "copilot-chat";
          version = "0.11.2023110301";
          sha256 = "sha256-tV5zMCxG5polCA8pAiJIY5HitqluRKl0QDWw7ncYiYY=";
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
          version = "2.0.392";
          sha256 = "sha256-OoXm8Jw2St6bpZ1lQr/hox/mdyOc8coK/0xu3NUl+Bo=";
        }
        {
          publisher = "bierner";
          name = "markdown-footnotes";
          version = "0.1.1";
          sha256 = "sha256-h/Iyk8CKFr0M5ULXbEbjFsqplnlN7F+ZvnUTy1An5t4=";
        }
        {
          publisher = "bufbuild";
          name = "vscode-buf";
          version = "0.5.2";
          sha256 = "sha256-fhGDMGhA/ag4jKo733gGGz6+UoDKKISzXjcnsx5eooI=";
        }
        {
          publisher = "flowtype";
          name = "flow-for-vscode";
          version = "2.2.1";
          sha256 = "sha256-zTxx7aUaoQhkqviB8Oi0JC1JVqFg5rEudtXuMa4yPc0=";
        }
        {
          publisher = "mrded";
          name = "railscasts";
          version = "0.0.4";
          sha256 = "sha256-vjfoeRW+rmYlzSuEbYJqg41r03zSfbfuNCfAhHYyjDc=";
        }
        {
          publisher = "ms-python";
          name = "black-formatter";
          version = "2023.7.13071012";
          sha256 = "sha256-bZs/xpDUWyEZcfPRNztFZQcVNdFJ14pa8lkgZp+iG/U=";
        }
        {
          publisher = "ms-python";
          name = "isort";
          version = "2023.11.13071012";
          sha256 = "sha256-jvsrZZud4tCDJDwkItk8vUp80BtDtr5SQWTnDsJWsXM=";
        }
        {
          publisher = "stylelint";
          name = "vscode-stylelint";
          version = "1.3.0";
          sha256 = "sha256-JoCa2d0ayBEuCcQi3Z/90GJ4AIECVz8NCpd+i+9uMeA=";
        }
      ];
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
        in
        pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "mkhl";
            name = "direnv";
            version = "0.6.1";
            sha256 = "sha256-5/Tqpn/7byl+z2ATflgKV1+rhdqj+XMEZNbGwDmGwLQ=";
          }
        ] ++ map (loadAfter [ "mkhl.direnv" ]) config.programs.vscode.direnvSensitiveExtensions;
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

        "[proto3]" = {
          "editor.defaultFormatter" = "bufbuild.vscode-buf";
        };

        "[python]" = {
          "editor.defaultFormatter" = "ms-python.black-formatter";
          "editor.formatOnSave" = true;
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = true;
          };
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

        "buf.binaryPath" = "${pkgs.buf}/bin/buf";

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

        "emmet.includeLanguages" = {
          "phoenix-heex" = "html";
        };

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

        "isort.args" = [ "--profile" "black" ];

        "javascript.suggest.autoImports" = false;

        "lldb.library" = "${pkgs.lldb.lib}/lib/liblldb.so";

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.rnix-lsp}/bin/rnix-lsp";

        "protoc.options" = [
          "-I${config.xdg.cacheHome}/buf/v1/module/buf.build"
        ];
        "protoc.path" = "${pkgs.protobuf}/bin/protoc";

        "python.formatting.provider" = "none";

        "stylelint.validate" = [ "css" "postcss" ];

        "tailwindCSS.includeLanguages" = {
          "elixir" = "html";
          "phoenix-heex" = "html";
        };

        "telemetry.enableTelemetry" = false;

        "typescript.suggest.autoImports" = false;

        "update.mode" = "none";

        "window.titleBarStyle" = "native";
        "window.zoomLevel" = 0;

        "workbench.colorTheme" = "RailsCasts";
        "workbench.editor.untitled.hint" = "hidden";
      };
    };
  };
}
