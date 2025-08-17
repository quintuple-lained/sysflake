{ pkgs
, ...
}:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-git;
    extraPackages =
      epkgs: with epkgs; [
        use-package
        straight
        base16-theme
        dashboard
        all-the-icons

        ace-jump-mode
        smartparens
        rainbow-delimiters
        projectile
        ranger
        magit
        git-gutter
        git-gutter-fringe
        lsp-ui
        rustic
        flycheck
        elgot
        markdown-mode
        yaml-mode
        json-mode
        toml-mode
        org-roam
        vterm
        w3m
        vdiff
        latex-preview-pane
      ];
  };

  home.file = {
    ".emacs.d/init.el".text = ''
      (defun efs/display-startup-time ()
        (message "Emacs loaded in %s with %d garbage collections."
                 (format "%.2f seconds"
                         (float-time
                          (time-subtract after-init-time before-init-time)))
                 gcs-done))

      (setq debug-on-error t)
      (setq debug-on-quit t)

      ;; Bootstrap straight.el
      (defvar bootstrap-version)
      (let ((bootstrap-file
             (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
            (bootstrap-version 5))
        (unless (file-exists-p bootstrap-file)
          (with-current-buffer
              (url-retrieve-synchronously
               "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
               'silent 'inhibit-cookies)
            (goto-char (point-max))
            (eval-print-last-sexp)))
        (load bootstrap-file nil 'nomessage))

      ;; Configure straight.el with use-package
      (straight-use-package 'use-package)
      (setq straight-use-package-by-default t)

      ;; Performance optimization
      (setq gc-cons-threshold (* 100 1024 1024))

      ;; Reset gc-cons-threshold after initialization
      (add-hook 'after-init-hook
                (lambda ()
                  (setq gc-cons-threshold (* 10 1024 1024))))

       ;; Load core Emacs configuration
       (load "~/.emacs.d/basics.el")

       ;; Load package management configuration
       (load "~/.emacs.d/modules/packages.el")

       (load "~/.emacs.d/modules/org.el")

      (add-hook 'emacs-startup-hook #'efs/display-startup-time)

      (custom-set-variables
       ;; custom-set-variables was added by Custom.
       ;; If you edit it by hand, you could mess it up, so be careful.
       ;; Your init file should contain only one such instance.
       ;; If there is more than one, they won't work right.
       '(package-selected-packages
         '(git-gutter-fringe smartparens lsp-ui vdiff json-mode org-roam magit rustic yaml-mode xterm-color w3m vterm toml ranger rainbow-delimiters projectile markdown-mode lv latex-preview-pane json-snatcher git-gutter fringe-helper flycheck dashboard dash compat base16-theme all-the-icons ace-jump-mode)))
      (custom-set-faces
       ;; custom-set-faces was added by Custom.
       ;; If you edit it by hand, you could mess it up, so be careful.
       ;; Your init file should contain only one such instance.
       ;; If there is more than one, they won't work right.
       '(org-headline-done ((((class color) (min-colors 16) (background dark)) (:strike-through t)))))

      (with-current-buffer "*Messages*"
        (write-region (point-min) (point-max) "~/.emacs.d/startup-errors.log"))
    '';

    ".emacs.d/basics.el".text = ''
      (use-package emacs
        :init
        ;; GUI Settings (executed before package loading)
        (blink-cursor-mode 0)
        (scroll-bar-mode 0)
        (tool-bar-mode 0)
        (menu-bar-mode 0)
        (setq visible-bell t
              x-underline-at-descent-line nil)             ;; Prettier underlines

        ;; Minibuffer Settings
        (setq enable-recursive-minibuffers t               ;; Use the minibuffer while already in it
              completion-cycle-threshold 1                ;; TAB cycles candidates
              tab-always-indent 'complete                 ;; Indent or complete with TAB
              completion-styles '(basic initials substring)
              completion-auto-help 'always
              completions-max-height 20
              completions-format 'one-column
              completions-group t
              completion-auto-select 'second-tab)

        ;; Backup and Autosave
        (setq make-backup-files t)                       ;; Enable backup files
        (defvar autosave-dir (concat "~/.emacs-autosaves/"))
        (make-directory autosave-dir t)
        (setq auto-save-filename-transforms `((".*" ,autosave-dir t)))

        (defvar backup-dir "~/.emacs-doc-backups/")
        (setq backup-directory-alist `((".*" . ,backup-dir)))

        :custom
        ;; Time and Date Display Settings
        (display-time-day-and-date t)
        (display-time-24hr-format t)
        (display-time-format "%Y-%m-%d %H:%M")             ;; ISO 8601 format for time
        (line-number-mode t)                               ;; Display line number
        (column-number-mode t)                             ;; Display column number

        ;; Auto Revert Mode
        (auto-revert-interval 1)
        (auto-revert-check-vc-info t)
        :config
        ;; Enable modes that need to load after package initialization
        (global-hl-line-mode 1)                            ;; Highlight current line
        (display-time-mode 1)                              ;; Show time in mode-line
        (pixel-scroll-precision-mode)                      ;; Precision scrolling in GUI
        (global-auto-revert-mode)                          ;; Automatically revert buffers
        (savehist-mode)                                    ;; Enable history saving

        ;; Keybindings
        (global-unset-key (kbd "C-z"))                     ;; Disable suspend key
        (define-key global-map (kbd "C-x C-o") 'other-window)  ;; Easier window switching
        (define-key global-map (kbd "C-o") (kbd "C-e RET"))    ;; Newline at end, Vim-style
        (define-key global-map (kbd "C-S-o") (kbd "C-p C-e RET")) ;; Newline above
        (define-key global-map (kbd "M-j") (kbd "C-u M-^"))      ;; Join next line

        ;; Language Modes Remapping via Tree-sitter
        (setq major-mode-remap-alist
              '((yaml-mode . yaml-ts-mode)
                (bash-mode . bash-ts-mode)
                (js2-mode . js-ts-mode)
                (typescript-mode . typescript-ts-mode)
                (json-mode . json-ts-mode)
                (css-mode . css-ts-mode)
                (python-mode . python-ts-mode)))

        ;; Hooks
        :hook
        (prog-mode . electric-pair-mode)                   ;; Auto-pairing in prog modes
        (text-mode . visual-line-mode))                    ;; Word wrap in text modes

      (use-package package
        :init
        (setq straight-use-package-by-default t)           ;; Initialize package system
        :custom
        (package-native-compile t)                         ;; Enable native compilation
        (setq package-archives '(("melpa" . "https://melpa.org/packages/")
                                 ("gnu" . "https://elpa.gnu.org/packages/")))
        (package-initialize)
        (unless package-archive-contents
        (package-refresh-contents))
        )

      ;; Utility Functions
      (defun today-org (directory)
        "Create an .org file in DIRECTORY named with the current date in ISO format."
        (interactive "DDirectory: ")
        (let* ((current-date (format-time-string "%Y-%m-%d"))
               (filename (concat current-date ".org"))
               (filepath (expand-file-name filename directory)))
          (if (file-exists-p filepath)
              (message "File already exists: %s" filepath)
            (write-region "" nil filepath)
            (find-file filepath)
            (message "Created file: %s" filepath))))

      (defun clear-kill-ring ()
        "Clear the kill ring."
        (interactive)
        (setq kill-ring nil)
        (message "Kill ring cleared."))

      (defun reload-current-config ()
        "Reload Emacs config from `user-emacs-directory`."
        (interactive)
        (let ((init-file (expand-file-name "init.el" user-emacs-directory)))
          (if (file-exists-p init-file)
              (load-file init-file)
            (message "No init.el found in %s" user-emacs-directory))))

      (defun swap-buffers-with-next-window ()
        "Swap the current buffer with the buffer in the next window."
        (interactive)
        (let* ((a (current-buffer))
               (b (window-buffer (next-window))))
          (switch-to-buffer b nil t)
          (save-selected-window
            (other-window 1)
            (switch-to-buffer a nil t))))

      (defun toggle-window-split ()
        "Toggle between horizontal and vertical window splits."
        (interactive)
        (if (= (count-windows) 2)
            (let* ((this-win-buffer (window-buffer))
                   (next-win-buffer (window-buffer (next-window)))
                   (this-win-edges (window-edges (selected-window)))
                   (splitter
                    (if (= (car this-win-edges)
                           (car (window-edges (next-window))))
                        'split-window-horizontally
                      'split-window-vertically)))
              (delete-other-windows)
              (funcall splitter)
              (set-window-buffer (selected-window) this-win-buffer)
              (set-window-buffer (next-window) next-win-buffer))))

      (global-set-key (kbd "C-x |") 'toggle-window-split)

      (provide 'basics)
    '';

    ".emacs.d/modules/packages.el".text = ''
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
    '';

    ".emacs.d/modules/org.el".text = ''
      (use-package org
               :hook ((org-mode . visual-line-mode)  ; wrap lines at word breaks
                     (org-mode . flyspell-mode))    ; spell checking!
               :config
               ;(setq org-list-automatic-rules 't)
               (org-babel-do-load-languages
                'org-babel-load-languages
                '((emacs-lisp . t)
                  (calc . t)
                  (python . t)
                  ))

               (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
            ;  (use-package os-csl)
               (add-to-list 'org-export-backends 'md)
               (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

               ;; Make exporting quotes better
               (setq org-export-with-smart-quotes t)
               (setq org-todo-keywords
                     '((sequence "TODO" "PROG" "WAIT" "|"  "DONE" "CNCL" "VOID")))
               (setq org-todo-keyword-faces
                     '(("TODO" . "red")
                       ("PROG" . "magenta")
                       ("WAIT" . "orange")
                       ("DONE" . "green")
                       ("CNCL" . "olive drab")
                       ("VOID" . "dim gray")))
               (setq org-image-actual-width nil)
               (setq org-tag-alist '(
                                     ;; locale
                                     (:startgroup)
                                     ("home" . ?h)
                                     ("work" . ?w)
                                     ("school" . ?s)
                                     (:endgroup)
                                     (:newline)
                                     ;; scale
                                     (:startgroup)
                                     ("one-shot" . ?o)
                                     ("project" . ?j)
                                     ("tiny" . ?t)
                                     (:endgroup)
                                     ;; misc
                                     ("meta")
                                     ("review")
                                     ("reading")))
               (custom-set-faces
                ;; custom-set-faces was added by Custom.
                ;; If you edit it by hand, you could mess it up, so be careful.
                ;; Your init file should contain only one such instance.
                ;; If there is more than one, they won't work right.
                '(org-headline-done ((((class color) (min-colors 16) (background dark)) (:strike-through t)))))
               )

            (use-package org-roam
              :config
              (setq org-roam-directory (file-truename "~/org-roam"))
              (org-roam-db-autosync-mode)
              )

            (provide 'org-settings)
    '';
    ".emacs.d/.gitignore".text = ''
      /auto-save-list
      /eln-cache
      /elpa
      /transient
    '';
    ".emacs-autosaves/.keep".text = "";
    ".emacs-doc-backups/.keep".text = "";
  };

  home.packages = with pkgs; [
    cmake
    libtool
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    texlive.combined.scheme-basic
    rust-analyzer
    rustfmt
    clippy
    git
    w3m
    fish
  ];
}
