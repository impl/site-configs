;;; my-mode-line.el --- Configure the mode line  -*- lexical-binding: t; -*-

;; SPDX-FileCopyrightText: 2025-2026 Noah Fontes
;;
;; SPDX-License-Identifier: CC-BY-NC-SA-4.0

;;; Commentary:

;;; Code:

(defun my-vc-mode-state-icon (state)
  (cond ((memq state '(added edited))
         (nerd-icons-mdicon "nf-md-pencil_plus"))
        ((eq state 'needs-merge)
         (nerd-icons-codicon "nf-cod-git_pull_request_new_changes"))
        ((eq state 'needs-update)
         (nerd-icons-codicon "nf-cod-git_pull_request_go_to_changes"))
        ((eq state 'conflict)
         (nerd-icons-codicon "nf-cod-bracket_error"))
        ((memq state '(removed unregistered))
         (nerd-icons-mdicon "nf-md-pencil_minus"))
        (t
         (nerd-icons-mdicon "nf-md-marker_check"))))

(defun my-vc-mode-format ()
  (require 'vc)
  (when vc-mode
    (let ((backend (vc-deduce-backend))
          (state-icon (my-vc-mode-state-icon (vc-state buffer-file-name))))
      (replace-regexp-in-string (format "^\s*%s." backend) state-icon vc-mode))))

(setcdr (assq 'vc-mode mode-line-format)
        '((:eval (my-vc-mode-format))))

(provide 'my-mode-line)

;;; my-mode-line.el ends here
