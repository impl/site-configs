# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    plugins = [
      {
        name = "virtualenv-prompt";
        src = pkgs.fetchFromGitHub {
          owner = "tonyseek";
          repo = "oh-my-zsh-virtualenv-prompt";
          rev = "a4772f1132f4423b98f36834d4389462bed16d4c";
          sha256 = "0sxq5mah4ry44d99f9ivr51acrlbgqjwsjr1vvjkl6ld8q4d62vw";
        };
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "mercurial"
        "history-substring-search"
        "kubectl"
      ];
      custom = "${./oh-my-zsh-custom}";
      theme = "impl";
    };
    initContent = ''
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=white,bold'
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'

      zstyle ':completion:*:*:*:*:*' menu select

      zstyle ':completion:*:matches' group yes
      zstyle ':completion:*:options' description yes
      zstyle ':completion:*:options' auto-description '%d'
      zstyle ':completion:*:corrections' format '%B%F{green}Ꞩ %d%f'
      zstyle ':completion:*:descriptions' format '%B%F{yellow}⮁ %d%f'
      zstyle ':completion:*:messages' format '%B%F{purple}» %d%f'
      zstyle ':completion:*:warnings' format '%B%F{red}Ɇ no match%f'
      zstyle ':completion:*' format '%B%F{yellow}⮁ %d%f'
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*' verbose yes

      zstyle ':completion:*' completer _expand _complete _correct _approximate
      zstyle ':completion:*:match:*' original only
      zstyle ':completion:*:approximate:*' max-errors 1 numeric
      zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

      zstyle ':completion:*:functions' ignored-patterns '_*'
    '';
  };

  home.file.".choysh".source = "${pkgs.zsh}${pkgs.zsh.shellPath}";
}
