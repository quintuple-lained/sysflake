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
