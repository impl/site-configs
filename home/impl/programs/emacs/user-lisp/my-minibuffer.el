;;; my-minibuffer.el --- Configure the minibuffer  -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(setq enable-recursive-minibuffers t
      read-extended-command-predicate #'command-completion-default-include-p
      minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))

(provide 'my-minibuffer)

;;; my-minibuffer.el ends here
