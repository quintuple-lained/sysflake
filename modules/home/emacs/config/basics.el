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

        
      	;; backup things
              (setq make-backup-files t)
      	
      	(defvar backup-dir "~/.emacs.d/backups")
              (defvar autosave-dir (concat "~/.emacs-autosaves/"))
      	(make-directory backup-dir t)
              (make-directory autosave-dir t)

      	(setq backup-directory-alist `((".*" . ,backup-dir)))
      	(setq version-control t)
      	(setq keep-new-versions 6)
      	(setq kept-old-versions 2)
      	(setq delete-old-versions t)

      	(setq auto-save-file-name-transforms `((".*" , autosave-dir t)))
      	(setq auto-save-default t)
      	(setq auto-save-timeout 20)
      	(setq auto-save-interval 200)

      	(setq create-lockfiles nil)

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
