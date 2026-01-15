;;; my-railscasts-theme.el --- Set up the RailsCasts theme  -*- lexical-binding: t; -*-

;; SPDX-FileCopyrightText: 2025-2026 Noah Fontes
;;
;; SPDX-License-Identifier: CC-BY-NC-SA-4.0

;;; Commentary:

;;; Code:

(deftheme my-railscasts "A RailsCasts-derived color theme.")

(defvar my-railscasts-colors-alist
  '(("my-railscasts-orange"   . "#fc623b")
    ("my-railscasts-orange+1" . "#f47454")
    ("my-railscasts-orange+2" . "#cc7833")
    ("my-railscasts-brown"    . "#bc9458")
    ("my-railscasts-pink-1"   . "#ffbd96")
    ("my-railscasts-pink"     . "#ffa78d")
    ("my-railscasts-pink+1"   . "#ffacc1")
    ("my-railscasts-pink+2"   . "#ffaae7")
    ("my-railscasts-pink+3"   . "#dd75c9")
    ("my-railscasts-gold-1"   . "#d38e39")
    ("my-railscasts-gold"     . "#ffc66d")
    ("my-railscasts-gold+1"   . "#c3a138")
    ("my-railscasts-cream-1"  . "#fff7d0")
    ("my-railscasts-cream"    . "#fffade")
    ("my-railscasts-yellow"   . "#f9f871")
    ("my-railscasts-blue-3"   . "#6d9cbe")
    ("my-railscasts-blue-2"   . "#4c8077")
    ("my-railscasts-blue-1"   . "#00869a")
    ("my-railscasts-blue"     . "#00bbef")
    ("my-railscasts-blue+1"   . "#0095cb")
    ("my-railscasts-blue+2"   . "#00a1ec")
    ("my-railscasts-blue+3"   . "#30444e")
    ("my-railscasts-green-1"  . "#519f50")
    ("my-railscasts-green"    . "#a5c621")
    ("my-railscasts-purple-1" . "#8ea8fc")
    ("my-railscasts-purple"   . "#9f7bc3")
    ("my-railscasts-purple+1" . "#d7b0fc")
    ("my-railscasts-purple+2" . "#d0d0ff")
    ("my-railscasts-charcoal" . "#4c4452")
    ("my-railscasts-black"    . "#202020")
    ("my-railscasts-black+1"  . "#2a2a2a"))
  "List of colors available for the theme.")

(defmacro my-railscasts-with-color-variables (&rest body)
  "Let-bind all colors defined in `my-railscasts-color-alist` around BODY."
  (declare (indent defun))
  `(let ((class '((class color) (min-colors 89)))
	       ,@(mapcar (lambda (cons)
		                 (list (intern (car cons)) (cdr cons)))
		               my-railscasts-colors-alist))
     ,@body))

(my-railscasts-with-color-variables
  (custom-theme-set-faces
   'my-railscasts

   `(default ((t (:foreground ,my-railscasts-cream :background ,my-railscasts-black))))
   `(cursor ((t (:background ,my-railscasts-cream-1))))
   `(hl-line ((t (:background ,my-railscasts-black+1))))
   `(region ((t (:background ,my-railscasts-blue+3))))
   `(highlight ((t (:background ,my-railscasts-black+1))))
   `(success ((t (:foreground ,my-railscasts-green-1))))
   `(warning ((t (:foreground ,my-railscasts-orange+1))))
   `(error ((t (:foreground ,my-railscasts-orange :weight bold))))
   `(minibuffer-prompt ((t (:foreground ,my-railscasts-yellow))))
   `(fringe ((t (:background ,my-railscasts-black+1))))
   `(line-number ((t (:foreground ,my-railscasts-charcoal :background ,my-railscasts-black+1))))
   `(match ((t (:weight bold))))
   `(isearch ((t (:foreground ,my-railscasts-cream-1 :background ,my-railscasts-blue-1))))
   `(lazy-highlight ((t (:inherit isearch :background ,my-railscasts-charcoal))))

   ;; mode-line
   `(mode-line ((t (:foreground ,my-railscasts-cream-1 :background ,my-railscasts-black+1 :overline ,my-railscasts-cream-1 :box (:line-width 3 :style flat-button)))))
   `(mode-line-active ((t (:inherit mode-line))))
   `(mode-line-inactive ((t (:foreground ,my-railscasts-blue+3 :background ,my-railscasts-black :overline ,my-railscasts-blue+3 :inherit mode-line))))

   ;; window-divider
   `(window-divider ((t (:foreground ,my-railscasts-blue+3))))

   ;; font-lock
   `(font-lock-type-face ((t (:foreground ,my-railscasts-cream-1))))
   `(font-lock-builtin-face ((t (:foreground ,my-railscasts-cream-1))))
   `(font-lock-constant-face ((t (:foreground ,my-railscasts-blue-3))))
   `(font-lock-string-face ((t (:foreground ,my-railscasts-green))))
   `(font-lock-doc-face ((t (:foreground ,my-railscasts-green-1))))
   `(font-lock-number-face ((t (:foreground ,my-railscasts-green))))
   `(font-lock-operator-face ((t (:foreground ,my-railscasts-cream-1))))
   `(font-lock-keyword-face ((t (:foreground ,my-railscasts-orange+2))))
   `(font-lock-variable-name-face ((t (:foreground ,my-railscasts-purple+2))))
   `(font-lock-function-name-face ((t (:foreground ,my-railscasts-gold))))
   `(font-lock-comment-face ((t (:foreground ,my-railscasts-brown))))
   `(font-lock-comment-delimiter-face ((t (:inherit font-lock-comment-face))))
   `(font-lock-warning-face ((t (:foreground ,my-railscasts-orange :weight bold))))

   ;; show-paren
   `(show-paren-mismatch ((t (:foreground ,my-railscasts-black :background ,my-railscasts-orange))))
   `(show-paren-match ((t (:background ,my-railscasts-charcoal :weight bold))))

   ;; envrc
   '(envrc-mode-line-on-face ((t (:inherit unspecified))))
   '(envrc-mode-line-none-face ((t (:inherit unspecified))))
   '(envrc-mode-line-error-face ((t (:strike-through t))))

   ;; racket
   `(racket-keyword-argument-face ((t (:foreground ,my-railscasts-cream-1))))

   ;; rainbow-delimiters
   '(rainbow-delimiters-base-error-face ((t (:inherit error))))
   `(rainbow-delimiters-depth-1-face ((t (:foreground ,my-railscasts-purple+1))))
   `(rainbow-delimiters-depth-2-face ((t (:foreground ,my-railscasts-blue+1))))
   `(rainbow-delimiters-depth-3-face ((t (:foreground ,my-railscasts-yellow))))
   `(rainbow-delimiters-depth-4-face ((t (:foreground ,my-railscasts-pink-1))))
   `(rainbow-delimiters-depth-5-face ((t (:foreground ,my-railscasts-purple-1))))
   `(rainbow-delimiters-depth-6-face ((t (:foreground ,my-railscasts-blue+2))))
   `(rainbow-delimiters-depth-7-face ((t (:foreground ,my-railscasts-gold-1))))
   `(rainbow-delimiters-depth-8-face ((t (:foreground ,my-railscasts-pink+3))))
   `(rainbow-delimiters-depth-9-face ((t (:foreground ,my-railscasts-charcoal))))))

(custom-theme-set-variables
 'my-railscasts

 '(window-divider-default-right-width 1)
 '(window-divider-default-bottom-width 1))

;;;###autoload
(and load-file-name
     (boundp 'custom-theme-load-path)
     (add-to-list 'custom-theme-load-path (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'my-railscasts)

;;; my-railscasts-theme.el ends here
