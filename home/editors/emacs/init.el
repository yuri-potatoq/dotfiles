(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

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

;; fsharp lsp
(use-package fsharp-mode
  :defer t
  :ensure t)

;; Enable Evil
(use-package evil :ensure t)
(evil-mode 1)


;; Kaolin theme
(use-package kaolin-themes
  :config
  (load-theme 'kaolin-aurora t)
  (kaolin-treemacs-theme))

(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status)
              ("C-c C-c e" . lsp-rust-analyzer-expand-macro)
              ("C-c C-c d" . dap-hydra)
              ("C-c C-c h" . lsp-ui-doc-glance))
;;  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  ;;(add-hook 'rustic-mode-hook 'rk/rustic-mode-hook)
)


(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; lsp-mode
(use-package lsp-mode 
  :hook
    ((lsp-mode . lsp-enable-which-key-integration))
    ((go-ts-mode . lsp))
    ((rust-ts-mode . lsp))
    ((rustic-mode . lsp))
    ((fsharp-mode . lsp)))

;; https://gluer.org/blog/2023/using-go-on-gnu-emacs-29-or-later/
(use-package treesit
  :config
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
  (setq rust-format-on-save t)
  :ensure nil
  :preface  
  (dolist (mapping '((go-mode . go-ts-mode) 
                     (rust-mode . rust-ts-mode) ))
    (add-to-list 'major-mode-remap-alist mapping))
  :init
  (add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
  (add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-mod-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode)))


;; lsp utils
(use-package company)
(use-package which-key :config (which-key-mode))

(setq lsp-keymap-prefix "C-c l")
(setq lsp-enable-file-watchers t)


;; lsp java setup
;; KILLER LINE
;; (use-package lsp-java)
;; (use-package lsp-java :config (add-hook 'java-mode-hook 'lsp))

;; (use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
;; (use-package dap-java :ensure nil)


;; go-lsp setup
(add-hook 'go-mode-hook 'lsp)



