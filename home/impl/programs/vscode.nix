# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (old: {
      buildInputs = old.buildInputs or [] ++ [ pkgs.makeWrapper ];
      postInstall = old.postInstall or [] ++ [ ''
        wrapProgram $out/bin/code --add-flags '--force-disable-user-env'
      '' ];
    });
    extensions = let
      loadAfter = deps: pkg: pkg.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.jq pkgs.moreutils ];
        preInstall = old.preInstall or [] ++ [ ''
          jq '.extensionDependencies |= . + $deps' \
            --argjson deps ${escapeShellArg (builtins.toJSON deps)} \
            package.json | sponge package.json
        '' ];
      });
    in
      pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "cab404";
          name = "vscode-direnv";
          version = "1.0.0";
          sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
        }
      ] ++ map (loadAfter [ "cab404.vscode-direnv" ]) (
        with pkgs.vscode-extensions; [
          bbenoist.nix
          editorconfig.editorconfig
          golang.go
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "mrded";
            name = "railscasts";
            version = "0.0.4";
            sha256 = "sha256-vjfoeRW+rmYlzSuEbYJqg41r03zSfbfuNCfAhHYyjDc=";
          }
          {
            publisher = "stkb";
            name = "rewrap";
            version = "1.14.0";
            sha256 = "sha256-qRwKX36a1aLzE1tqaOkH7JfE//pvKdPZ07zasPF3Dl4=";
          }
        ]
      );
    userSettings = {
      "[go]" = {
        "editor.snippetSuggestions" = "none";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = true;
        };
      };

      "[nix]" = {
        "editor.tabSize" = 2;
      };

      "docker.showStartPage" = false;

      "editor.fontFamily" = "'Fira Code'";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 14;
      "editor.minimap.enabled" = true;
      "editor.suggestSelection" = "first";

      "extensions.autoUpdate" = false;
      "extensions.ignoreRecommendations" = true;
      "extensions.showRecommendationsOnlyOnDemand" = true;

      "explorer.autoReveal" = true;
      "explorer.confirmDragAndDrop" = false;

      "files.autoSave" = "off";

      "update.mode" = "none";

      "telemetry.enableTelemetry" = false;

      "window.titleBarStyle" = "native";
      "window.zoomLevel" = 0;

      "workbench.colorTheme" = "RailsCasts";
      "workbench.editor.untitled.hint" = "hidden";
    };
  };
}
