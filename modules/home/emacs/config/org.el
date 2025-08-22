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
