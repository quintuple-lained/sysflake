(use-package base16-theme
        :config
        (load-theme 'base16-gruvbox-dark-soft t)
        )

      (use-package markdown-mode
        :hook ((markdown-mode . visual-line-mode))
        )

      (use-package yaml-mode)

      (use-package json-mode)

      (use-package ranger)

      (use-package w3m)

      (use-package vdiff)

      (use-package projectile)

      (use-package toml-mode)

      (use-package rainbow-delimiters
        :config
        (rainbow-delimiters-mode t)
        )

      (use-package latex-preview-pane
        :config
        (latex-preview-pane-enable))

      (use-package lsp-ui
        :commands
        (lsp-ui-mode)
        )

      (use-package vterm
        :custom
        (setq-default explicit-shell-file-name "/bin/fish")
        )

      (use-package smartparens
        :bind
        (
         ("<localleader>(" . sp-wrap-round)
         ("<localleader>{" . sp-wrap-curly)
         ("<localleader>[" . sp-wrap-square)
         ("<localleader>DEL" . sp-splice-sexp-killing-backward)
         )
        )

      (use-package ace-jump-mode
        :bind
        ("C-<tab>" . ace-jump-mode)
        )

      (use-package git-gutter
        :hook
        (prog-mode . git-gutter-mode)
        :config
        (setq git-gutter:update-interval 0.02)
        )

      (use-package git-gutter-fringe
        :config
        (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
        (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
        (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom)
        )

      (use-package rustic
        :config
        (setq rustic-format-on-save t)
        :hook (
               (rust-mode-hook . cargo-minor-mode)
               (prog-mode-hook . display-line-numbers-mode)
               (rustic-mode . eglot-ensure)
               )
        :custom
        (rustic-cargo-use-last-stored-arguments t)
        (setq rustic-lsp-server 'rust-analyzer)
        )

      (use-package magit)

      (use-package all-the-icons
        :if
        (display-graphic-p)
        )

      (use-package dashboard
        :config
        (setq dashboard-items '((recents . 5)
                                (bookmarks . 5)
                                (projects . 5)
                                (agenda . 5)
                                (registers . 5)))
        (setq dashboard-banner-logo-title "My Emacs config: writing a clusterfuck, one commit at a time")
        (setq dashboard-startup-banner "~/.emacs.d/assets/gentoo_logo500.png")
        (setq dashboard-icon-type 'all-the-icons)
        (setq dashboard-center-content t)
        (dashboard-setup-startup-hook)
        )

      (provide 'packages)
