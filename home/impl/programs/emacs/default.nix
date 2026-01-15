# SPDX-FileCopyrightText: 2025-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
    extraPackages = emacsPkgs: with emacsPkgs; [
      company
      company-pollen
      consult
      diminish
      dired-sidebar
      dired-subtree
      editorconfig
      envrc
      embark
      embark-consult
      go-tag
      godoctor
      lsp-mode
      lsp-pyright
      lsp-ui
      marginalia
      nerd-icons
      nerd-icons-dired
      nix-mode
      pollen-mode
      orderless
      racket-mode
      rainbow-delimiters
      rainbow-mode
      rustic
      treesit-grammars.with-all-grammars
      undo-tree
      use-package
      vertico
    ];
  };

  home.packages = with pkgs; [
    nerd-fonts.symbols-only
  ];

  services.emacs = {
    enable = true;
    socketActivation.enable = true;
    defaultEditor = true;
  };

  systemd.user.services.emacs.Service.Environment =
    [ "PATH=${config.home.profileDirectory}/bin:${makeBinPath [ pkgs.basedpyright pkgs.beamPackages.elixir-ls pkgs.coreutils pkgs.racket ]}" ];

  home.file.".emacs.el".source = pkgs.replaceVars ./init.el {
    userLispDir = ./user-lisp;
    generalFontFamily = config.profiles.theme.font.generalFont;
    codeFontFamily = config.profiles.theme.font.codeFont;
    fontHeight = 11 * 10; # 1/10th points
  };
}
