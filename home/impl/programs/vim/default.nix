# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  xdg.dataFile."vim/backups/.keep".source = builtins.toFile "keep" "";

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      argtextobj-vim
      base16-vim
      csapprox
      ctrlp-vim
      direnv-vim
      editorconfig-vim
      nerdtree
      supertab
      syntastic
      tcomment_vim
      vim-airline
      vim-airline-themes
      vim-beancount
      vim-elixir
      vim-flake8
      vim-fugitive
      vim-git
      vim-go
      vim-indent-object
      vim-javascript
      vim-json
      vim-jsonnet
      vim-nix
      vim-puppet
      vim-python-pep8-indent
      vim-surround
      vim-terraform
      vim-yaml
      zoomwintab-vim
    ];
    settings = {
      background = "dark";
      backupdir = [ "~/${builtins.dirOf config.xdg.dataFile."vim/backups/.keep".target}" ];
      directory = [ "~/${builtins.dirOf config.xdg.dataFile."vim/backups/.keep".target}" ];
      expandtab = true;
      number = true;
      shiftwidth = 4;
      smartcase = true;
      tabstop = 4;
    };
    extraConfig = builtins.readFile ./vimrc;
  };
}
