# SPDX-FileCopyrightText: 2021 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
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
      ] ++ map (loadAfter [ "mkhl.direnv" ]) (
        with pkgs.vscode-extensions; [
          bbenoist.nix
          editorconfig.editorconfig
          golang.go
          matklad.rust-analyzer
          stkb.rewrap
          vadimcn.vscode-lldb
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "GitHub";
            name = "copilot";
            version = "1.43.6621";
            sha256 = "sha256-JrD0t8wSvz8Z1j6n0wfkG6pfIjt2DNZmfAbaLdj8olQ=";
          }
          {
            publisher = "mrded";
            name = "railscasts";
            version = "0.0.4";
            sha256 = "sha256-vjfoeRW+rmYlzSuEbYJqg41r03zSfbfuNCfAhHYyjDc=";
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

      "[rust]" = {
        "editor.formatOnSave" = true;
      };

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

      "files.autoSave" = "off";

      "update.mode" = "none";

      "telemetry.enableTelemetry" = false;

      "window.titleBarStyle" = "native";
      "window.zoomLevel" = 0;

      "workbench.colorTheme" = "RailsCasts";
      "workbench.editor.untitled.hint" = "hidden";

      "lldb.library" = "${pkgs.lldb.lib}/lib/liblldb.so";
    };
  };
}
