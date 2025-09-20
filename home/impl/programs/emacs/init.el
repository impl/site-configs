;;; init.el --- Emacs initialization routines  -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'package)

(package-initialize)

(eval-when-compile
  (require 'use-package))

;; company
(use-package company
  :diminish
  :config (global-company-mode))
(use-package company-pollen)

;; consult
(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (consult-customize))

;; diminish
(use-package diminish)

;; dired
(use-package dired-sidebar
  :bind (("C-x C-d" . dired-sidebar-toggle-sidebar))
  :commands (dired-sidebar-toggle-sidebar)
  :custom
  (dired-sidebar-theme 'nerd-icons)
  (dired-sidebar-should-follow-file t))
(use-package dired-subtree)

;; editorconfig
(use-package editorconfig
  :diminish
  :init (setq editorconfig-lisp-use-default-indent t)
  :config (editorconfig-mode 1))

;; embark
(use-package embark
  :bind (("C-." . embark-act)
         ("M-." . embark-dwim)
         ("C-h B" . embark-bindings)))
(use-package embark-consult
  :hook (embark-consult-mode . consult-preview-at-point-mode))

;; envrc
(use-package envrc
  ;; This isn't the recommended configuration but it seems to allow envrc to load before every other
  ;; mode, including minor modes requested by major modes.
  :hook change-major-mode-after-body
  :custom
  (envrc-none-lighter nil)
  (envrc-on-lighter '(" " (:propertize "envrc" face envrc-mode-line-on-face)))
  (envrc-error-lighter '(" " (:propertize "envrc" face envrc-mode-line-error-face))))

;; flymake
(use-package flymake
  :custom
  (flymake-show-diagnostics-at-end-of-line t))

;; go
(use-package go-ts-mode
  :hook (go-ts-mode . my-go-ts-mode-hook)
  :init
  (defun my-go-ts-mode-hook ()
    (setq indent-tabs-mode 1)
    (setq tab-width 4))
  :mode "\\.go\\'"
  :bind
  (:map go-ts-mode-map
        ("RET" . reindent-then-newline-and-indent)
        ("M-RET" . newline))
  :custom
  (go-ts-mode-indent-offset 4)
  (lsp-go-analyses '((nilness . t)
                     (shadow . t)
                     (unusedwrite . t)))
  (lsp-go-codelenses '((test . t)
                       (tidy . t)
                       (upgrade_dependency . t)
                       (vendor . t)
                       (run_govulncheck . t))))
(use-package go-tag
  :after go-ts-mode)
(use-package godoctor)

;; lsp
(use-package lsp-mode
  :hook ((go-ts-mode) . my-lsp-deferred)
  :init
  (defun my-lsp-deferred ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t)
    (lsp-deferred))
  :commands lsp)
(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-header t)
  (lsp-ui-doc-position 'top)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-include-signature t))

;; marginalia
(use-package marginalia
  :init (marginalia-mode))

;; nerd-icons
(use-package nerd-icons)
(use-package nerd-icons-dired
  :hook ((dired-mode . nerd-icons-dired-mode)
         (nerd-icons-dired-mode . my-dired-subtree-nerd-icons-hook))
  :init
  (defun my-dired-subtree-refresh-nerd-icons ()
    (interactive)
    (revert-buffer))
  (defun my-dired-subtree-nerd-icons-hook ()
    (when (require 'dired-subtree nil t)
      (if nerd-icons-dired-mode (advice-add #'dired-subtree-toggle :after #'my-dired-subtree-refresh-nerd-icons)
        (advice-remove #'dired-subtree-toggle #'my-dired-subtree-refresh-nerd-icons)))))

;; nix-mode
(use-package nix-mode)

;; orderless
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; pollen-mode
(use-package pollen-mode)

;; racket-mode
(use-package racket-mode
  :hook ((racket-mode racket-hash-lang-mode) . racket-xp-mode)
  :config
  (with-eval-after-load 'envrc
    ;; Allow Racket to automatically configure its back end path when loaded by envrc. See
    ;; https://github.com/greghendershott/racket-mode/issues/706.
    (defun my-racket-back-end-hook ()
      (when-let ((env-dir (and (eq envrc--status 'on)
                               (envrc--find-env-dir))))
        (unless (cl-find env-dir racket-back-end-configurations
                         :test (lambda (dir back-end) (equal dir (plist-get back-end :directory))))
          (when-let ((racket-path (executable-find "racket")))
            (message "Racket back end for %s set to %s." env-dir racket-path)
            (racket-add-back-end env-dir :racket-program racket-path)))))
    (add-to-list 'envrc-mode-hook #'my-racket-back-end-hook)))

;; rainbow-delimiters
(use-package rainbow-delimiters
  :hook (prog-mode conf-mode))

;; rainbow-mode
(use-package rainbow-mode
  :diminish
  :hook ((css-mode emacs-lisp-mode pollen-mode) . rainbow-mode))

;; undo-tree
(use-package undo-tree
  :diminish
  :custom (undo-tree-history-directory-alist `(("." . ,(expand-file-name "undo-tree" user-emacs-directory))))
  :config (global-undo-tree-mode))

;; vertico
(use-package vertico
  :init (vertico-mode))

;; Load my configuration.
(add-to-list 'load-path "@userLispDir@")
(require 'my-backup)
(require 'my-cursor)
(require 'my-minibuffer)
(require 'my-mode-line)
(require 'my-modes)
(require 'my-railscasts-theme)

;; Customize the theme.
;;
;; In daemon mode, it seems that some faces (like cursor, annoyingly) are automatically overridden
;; unless configured when the first frame is created, so hook into it instead.
(defun my-theme-setup ()
  (load-theme 'my-railscasts t)
  (set-face-attribute 'default nil :family "@codeFontFamily@" :height @fontHeight@)
  (set-face-attribute 'variable-pitch nil :family "@generalFontFamily@" :inherit 'default))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my-theme-setup)
  (my-theme-setup))

(provide 'init)

;;; init.el ends here
