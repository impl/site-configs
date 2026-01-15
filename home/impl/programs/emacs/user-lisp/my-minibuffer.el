;;; my-minibuffer.el --- Configure the minibuffer  -*- lexical-binding: t; -*-

;; SPDX-FileCopyrightText: 2025-2026 Noah Fontes
;;
;; SPDX-License-Identifier: CC-BY-NC-SA-4.0

;;; Commentary:

;;; Code:

(setq enable-recursive-minibuffers t
      read-extended-command-predicate #'command-completion-default-include-p
      minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))

(provide 'my-minibuffer)

;;; my-minibuffer.el ends here
