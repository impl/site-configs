;;; my-backup.el --- Configure settings for backing up buffers  -*- lexical-binding: t; -*-

;; SPDX-FileCopyrightText: 2025-2026 Noah Fontes
;;
;; SPDX-License-Identifier: CC-BY-NC-SA-4.0

;;; Commentary:

;;; Code:

(let ((backup-directory (expand-file-name "backup" user-emacs-directory))
      (lock-directory (expand-file-name "lock" user-emacs-directory))
      (auto-save-directory (expand-file-name "auto-save" user-emacs-directory)))
  (make-directory backup-directory t)
  (make-directory lock-directory t)
  (make-directory auto-save-directory t)
  (setq
   ;; Move backup files to a central location.
   backup-by-copying t
   backup-directory-alist `(("." . ,backup-directory))
   ;; Move lockfiles to a central location.
   create-lockfiles t
   lock-file-name-transforms `(("\\`/.*/\\([^/]+\\)\\'" ,(concat lock-directory "\\1") t))
   ;; Move autosave files to a central location.
   auto-save-file-name-transforms `(("\\`/.*/\\([^/]+\\)\\'" ,(concat auto-save-directory "\\1") t))))

(provide 'my-backup)

;;; my-backup.el ends here
