# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  sops.secrets."programs/git/config-send-email" = {
    sources = [
      { file = ./config-send-email.sops; }
    ];
  };

  home.file.".config/git/config-send-email" = {
    source = config.sops.secrets."programs/git/config-send-email".target;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    signing = {
      key = null;
      signByDefault = true;
      format = "openpgp";
    };
    settings = {
      alias = {
        "ci" = "commit";
        "st" = "status";
        "br" = "branch";
        "co" = "checkout";
        "df" = "diff";
        "who" = "shortlog -s --";
        "slog" = "log --graph --date=local --abbrev-commit --pretty='%Cred%h %Cblue%p %Creset— %Cgreen%aN %Cresetcommitted %Cgreen%ar%Creset: %s'";
      };
      user = {
        email = "noah@noahfontes.com";
        name = "Noah Fontes";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        ff = "only";
      };
      color = {
        status = "auto";
        branch = "auto";
        diff = "auto";
      };
      rerere = {
        enabled = true;
      };
      sendemail = {
        confirm = "always";
      };
    };
    ignores = [
      # NixOS
      "result"

      # direnv
      ".direnv/"
      ".envrc"

      # Editors
      ".calva/"
      ".clj-kondo/"
      ".elixir_ls/"
      ".lsp/"
      ".vscode/"
    ];
    includes = [
      {
        path = "${config.home.homeDirectory}/${config.home.file.".config/git/config-send-email".target}";
      }
      {
        condition = "gitdir:~/";
        contents = {
          url = {
            "git@github.com:" = { insteadOf = "https://github.com/"; };
          };
        };
      }
    ];
  };

  home.packages = [
    pkgs.git-repo
  ];
}
