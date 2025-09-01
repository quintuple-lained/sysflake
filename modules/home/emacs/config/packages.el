;; -*- mode: emacs-lisp; lexical-binding: t; -*-
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

      (use-package projectile
  :init (projectile-mode +1)
  :bind (:map projectile-mode-map
         ("C-c p" . projectile-command-map))
  :custom
  (projectile-completion-system 'default)
  (projectile-enable-caching t)
  (projectile-indexing-method 'alien)
  (projectile-sort-order 'recentf)
  (projectile-use-git-grep t)
  (projectile-switch-project-action #'projectile-dired)
  (projectile-project-search-path '("~/src/" "~/projects/"))
  :config
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  (add-to-list 'projectile-globally-ignored-directories ".git")
  (add-to-list 'projectile-globally-ignored-directories "target")
  (add-to-list 'projectile-globally-ignored-directories "__pycache__"))

(use-package nix-mode
             :mode "\\.nix\\'")

(use-package rg
  :bind (("M-s g" . rg)
         ("M-s d" . rg-dwim)
         ("M-s k" . rg-kill-saved-searches)
         ("M-s l" . rg-list-searches)
         ("M-s p" . rg-project)
         ("M-s r" . rg-literal)
         ("M-s s" . rg-save-search)
         ("M-s S" . rg-save-search-as-name)
         ("M-s t" . rg-literal))
  :config
  (rg-enable-default-bindings))


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

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package vterm
  :custom
  (setq-default explicit-shell-file-name "/bin/fish")
  :config
  ;; UTF-8 configuration for vterm
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  
  ;; Fix cursor positioning issues
  (setq vterm-set-bold-hightlight nil)
  (setq vterm-use-vterm-prompt-detection-method 'shell-integration)
	)

(use-package smartparens
  :hook ((prog-mode . smartparens-mode)
         (text-mode . smartparens-mode))
  :bind (:map smartparens-mode-map
         ("C-M-f" . sp-forward-sexp)
         ("C-M-b" . sp-backward-sexp)
         ("C-M-d" . sp-down-sexp)
         ("C-M-a" . sp-backward-down-sexp)
         ("C-M-e" . sp-up-sexp)
         ("C-M-u" . sp-backward-up-sexp)
         ("C-M-t" . sp-transpose-sexp)
         ("C-M-n" . sp-next-sexp)
         ("C-M-p" . sp-previous-sexp)
         ("C-M-k" . sp-kill-sexp)
         ("C-M-w" . sp-copy-sexp)
         ("M-<delete>" . sp-unwrap-sexp)
         ("M-<backspace>" . sp-backward-unwrap-sexp)
         ("C-<right>" . sp-forward-slurp-sexp)
         ("C-<left>" . sp-forward-barf-sexp)
         ("C-M-<left>" . sp-backward-slurp-sexp)
         ("C-M-<right>" . sp-backward-barf-sexp)
         ("M-D" . sp-splice-sexp)
         ("C-M-<delete>" . sp-splice-sexp-killing-forward)
         ("C-M-<backspace>" . sp-splice-sexp-killing-backward)
         ("C-S-<backspace>" . sp-splice-sexp-killing-around)
         ("C-]" . sp-select-next-thing-exchange)
         ("C-<left_bracket>" . sp-select-previous-thing)
         ("C-M-]" . sp-select-next-thing)
         ("M-F" . sp-forward-symbol)
         ("M-B" . sp-backward-symbol))
  :config
  (require 'smartparens-config)
  (sp-use-paredit-bindings)
  (show-paren-mode t))

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-command "multimarkdown")
  (markdown-live-preview-delete-export 'delete-on-export)
  (markdown-asymmetric-header t)
  (markdown-header-scaling t))

(use-package dockerfile-mode
  :mode "Dockerfile\\'")

(use-package color-rg
  :bind (("M-s M-s" . color-rg-search-input)
         ("M-s M-p" . color-rg-search-project)
         ("M-s M-f" . color-rg-search-input-in-current-file)))


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

      (use-package apheleia
  :init (apheleia-global-mode +1)
  :custom
  (apheleia-remote-algorithm 'cancel)
  :config
  ;; Add formatters as needed
  (setf (alist-get 'python-mode apheleia-mode-alist) 'black)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'black)
  (setf (alist-get 'rust-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'rust-ts-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'go-mode apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'js-mode apheleia-mode-alist) 'prettier-javascript)
  (setf (alist-get 'js-ts-mode apheleia-mode-alist) 'prettier-javascript)
  (setf (alist-get 'typescript-mode apheleia-mode-alist) 'prettier-typescript)
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'prettier-typescript)
  (setf (alist-get 'nix-mode apheleia-mode-alist) 'nixfmt))


      (use-package dashboard
        :config

          (defvar my-custom-strings '("there is more in life than work, like working on your emacs config!"
                              "have you considered that it might be a skill issue?"
                              "There you go, it was a skill issue!"
                              "Only three things are inevitable in life: death, taxes and emacs config changes"
                              "I use ~~gentoo~~ nixos btw"
                              "But what are the civilian appications?"
                              "Needs more ricing"
                              "I killed that buffer a long time ago"
                              "i made a new emacs tutorial video, its around one and a half... years long, i can send it to you via ftp"
                              "but emacs is not a text editor"
                              "DNA sequencing? emacs!"
ouse-package apheleia
  :init (apheleia-global-mode +1)
  :custom
  (apheleia-remote-algorithm 'cancel)
  :config
  ;; Add formatters as needed
  (setf (alist-get 'python-mode apheleia-mode-alist) 'black)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'black)
  (setf (alist-get 'rust-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'rust-ts-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'go-mode apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'js-mode apheleia-mode-alist) 'prettier-javascript)
  (setf (alist-get 'js-ts-mode apheleia-mode-alist) 'prettier-javascript)
  (setf (alist-get 'typescript-mode apheleia-mode-alist) 'prettier-typescript)
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'prettier-typescript)
  (setf (alist-get 'nix-mode apheleia-mode-alist) 'nixfmt))
                              "with jupiter you're modifying the states of the program, with emacs youre modifying the state of the art"
                              "saying emacs will die is like saying turing complete will die"
                              "ive also been diagnosed with severe hostility to vim users, but thats not a real disease of course, the real disease is vim"
                              "i dont have an ego! i killed that buffer a long time ago"
                              "i think stictly in elisp"
                              "you control undo the undo"
                              "i treat my whole life like a text buffer"
                              "lex freedman doesnt use emacs anymore? where is my deathnote..."
                              "vim is for dark people"
                              "space emacs? what are you, 5?"
                              "yeah you can do this in emacs, i mean i cant imagine wanting this but a mans emacs is his castle"
                              "you can bind the keybindings to shorter keybindings"
                              "but i will always use magit tho"
                              "oh that deletes the region, it doesnt kill it"
                              "no i want to keep modding so its fun when i start working"
                              "the only thing i do in this department is fix peoples emacs"
                              "people never quit emacs, they just die at some point"))

          (defvar my-banner-images '("~/.emacs.d/assets/nixos-queer.png"
                                     "~/.emacs.d/assets/nixos-default.png"
                                     "~/.emacs.d/assets/nixos-black.png"
                                     "~/.emacs.d/assets/nixos-white.png"))

            (defvar my-banner-titles '( "My Emacs config: writing a clusterfuck, one commit at a time"
                                        "Emacs: The only IDE that's also an operating system"
                                        "Emacs: Because why use many tools when one can do it all?"
                                        "Emacs: Making simple tasks complex since 1976"
                                        "Emacs: ofcourse theres a package for that"
                                        "Emacs: almost an operating system"
                                        "Emacs: Where 'scratch' is a buffer, not just an itch"))

            (defun random-element (list)
              "return a random elem)t from a LIST"
              (nth (random(length list)) list))

            (defun set-random-dashboard-elements ()
              "set random elements for the dashboard"
              (setq dashboard-banner-logo-title (random-element my-banner-titles))
              (setq dashboard-startup-banner (random-element my-banner-images)))

              (add-hook 'dashboard-mode-hook #'set-random-dashboard-elements)

        (setq dashboard-set-footer t 
              dashboard-footer-messages my-custom-strings)
        (setq dashboard-items '((recents . 5)
                                (bookmarks . 5)
                                (projects . 5)
                                (agenda . 5)
                                (registers . 5)))
        (setq dashboard-icon-type 'all-the-icons)
        (setq dashboard-center-content t)
        (setq initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name)))
        (dashboard-setup-startup-hook)
        )

      (provide 'packages)
