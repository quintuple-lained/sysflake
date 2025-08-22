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

          (defvar my-banner-images '("~/.emacs.d/assets/nixos-queer.svg"
                                     "~/.emacs.d/assets/nixos-default.svg"
                                     "~/.emacs.d/assets/nixos-black.svg"
                                     "~/.emacs.d/assets/nixos-white.svg"))

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

            (defvar set-random-dashboard-elements ()
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
