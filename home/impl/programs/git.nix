{ config, lib, machineConfig, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.git = {
    enable = true;
    userEmail = "noah@noahfontes.com";
    userName = "Noah Fontes";
    signing = {
      key = null;
      signByDefault = true;
      gpgPath = "${config.programs.gpg.package}/bin/gpg";
    };
    aliases = {
      "ci" = "commit";
      "st" = "status";
      "br" = "branch";
      "co" = "checkout";
      "df" = "diff";
      "who" = "shortlog -s --";
      "slog" = "log --graph --date=local --abbrev-commit --pretty='%Cred%h %Cblue%p %Creset— %Cgreen%aN %Cresetcommitted %Cgreen%ar%Creset: %s'";
    };
    ignores = [
      # NixOS
      "result"

      # direnv
      ".direnv/"
      ".envrc"

      # Editors
      ".vscode/"
    ];
    extraConfig = {
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
      url = {
        "git@github.com:" = { insteadOf = "https://github.com/"; };
      };
    };
  };
}
