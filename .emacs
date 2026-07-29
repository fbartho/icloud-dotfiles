(global-font-lock-mode 1)
;; Turn on tabs
(setq indent-tabs-mode t)
(setq-default indent-tabs-mode t)
(global-whitespace-mode 1)

;; Bind the TAB key
(global-set-key (kbd "TAB") 'self-insert-command)

;; Set the tab width
(setq default-tab-width 4)
(setq tab-width 4)
(setq c-basic-indent 4)
(setq c-basic-offset 4)
; Load el4r, which loads Xiki
;(add-to-list 'load-path "/Library/Ruby/Gems/2.0.0/gems/trogdoro-el4r-1.0.10/data/emacs/site-lisp/")
;(require 'el4r)
;(el4r-boot)
;(el4r-troubleshooting-keys)

;; Load Emacs Package manager "MELPA"
(require 'package) ;; You might already have this line
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;;Legacy?
;;(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
;;                    (not (gnutls-available-p))))
;;       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
;;  (add-to-list 'package-archives (cons "melpa" url) t))
;;(when (< emacs-major-version 24)
;;  ;; For important compatibility libraries like cl-lib
;;  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line
;;
;;(editorconfig-mode 1)

;;(use-package editorconfig
;;  :ensure t
;;  :config
;;  (editorconfig-mode 1))
