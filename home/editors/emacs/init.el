;; eval use-package as fast as possible
(eval-when-compile
  (require 'use-package))
  
;; disable impure packages
(setq package-archives nil
      package-enable-at-startup nil)

;; always ensure that use-package will download the needed packages
(setq use-package-always-ensure t)

;; git stuff
(use-package magit
  :ensure t
  :defer t
  :config
  (use-package forge :defer t)
  (use-package magit-todos
    :defer t
    :hook (magit-mode . magit-todos-mode)))

;; Enable Evil
(require 'evil)
(evil-mode 1)

;; lsp-mode
(use-package lsp-mode :hook ((lsp-mode . lsp-enable-which-key-integration)))

;; lsp utils
(use-package company)
(use-package flycheck)
(use-package which-key :config (which-key-mode))

(setq lsp-keymap-prefix "C-c l")
(setq lsp-enable-file-watchers t)


;; lsp java setup
(use-package lsp-java)
;; (use-package lsp-java :config (add-hook 'java-mode-hook 'lsp))

;; (use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
;; (use-package dap-java :ensure nil)


;; go-lsp setup
(add-hook 'go-mode-hook #'lsp)



