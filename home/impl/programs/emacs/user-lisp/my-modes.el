;;; my-modes.el --- Configure minor modes  -*- lexical-binding: t; -*-

;; SPDX-FileCopyrightText: 2025-2026 Noah Fontes
;;
;; SPDX-License-Identifier: CC-BY-NC-SA-4.0

;;; Commentary:

;;; Code:

;; Disable unnecessary UI components.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Highlight the current line.
(global-hl-line-mode 1)

;; Display line numbers next to the fringe.
(setq display-line-numbers-type 'visual
      display-line-numbers-current-absolute t
      display-line-numbers-width 4
      display-line-numbers-widen t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

;; Enable column numbering in the modeline.
(column-number-mode 1)

;; Parentheses matching.
(setq show-paren-style 'mixed)
(show-paren-mode 1)
(electric-pair-mode 1)

;; Save history across instances.
(savehist-mode 1)

;; Use a themed border between windows.
(setq window-divider-default-places t)
(window-divider-mode 1)

(provide 'my-modes)

;;; my-modes.el ends here
