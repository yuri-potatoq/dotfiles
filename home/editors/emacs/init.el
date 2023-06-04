;; Set up package.el to work with MELPA
;; (require 'package)
;; (add-to-list 'package-archives
;;              '("melpa" . "https://melpa.org/packages/"))
;; (package-initialize)
;; (package-refresh-contents)

;; Download Evil
;; (unless (package-installed-p 'evil)
;;   (package-install 'evil))

;; Enable Evil
(require 'evil)
(evil-mode 1)

;; lsp-mode
(require 'lsp-mode)

;; java setup
(require 'lsp-java)
(add-hook 'java-mode-hook #'lsp)
