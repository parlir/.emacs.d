;; Adding melpa to list of packages
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))


;; (defun delete-old-backups ()
;;   (message "Deleting old backup files...")
;;   (let ((week (* 60 60 24 7))
;; 	(current (float-time (current-time))))
;;     (dolist (file (directory-files temporary-file-directory t))
;;       (when (and (backup-file-name-p file)
;; 		 (> (- current (float-time (fifth (file-attributes file))))
;; 		    week))
;; 	(message "%s" file)
;; 	(delete-file file)))))

(defun set-backup ()
 (setq backup-directory-alist
	   `((".*" . ,temporary-file-directory)))
 (setq auto-save-file-name-transforms
       `((".*" ,temporary-file-directory t))))
(set-backup)
(setq-default truncate-lines 0)

(setq org-todo-keywords
      '((sequence "TODO" "IN-PROGRESS" "|" "DONE" )))

(use-package solarized-theme
  :ensure t)

;; Execute from shell so commands work on osx.
(use-package exec-path-from-shell
  :ensure t
  :init (progn (setq explicit-shell-file-name "/bin/zsh")
         (setq shell-file-name "/bin/zsh"))
  :config (progn
            (when (memq window-system '(mac ns x))
              (exec-path-from-shell-initialize))))


(defun reload-dir-locals-for-all-buffer-in-this-directory ()
  "For every buffer with the same `default-directory` as the 
current buffer's, reload dir-locals."
  (interactive)
  (let ((dir default-directory))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (equal default-directory dir)
          (my-reload-dir-locals-for-current-buffer))))))

(defun kill-all-buffers ()
  (interactive)
  (mapcar '(lambda (buffer) (kill-buffer buffer)) (buffer-list))
  )

;; - GLOBALS
(global-linum-mode 1)
;; Default start in fullscreen.
(add-hook 'after-init-hook '(lambda () (toggle-frame-fullscreen)))
;; -- Key bindings
(global-set-key (kbd "C-c c f") 'toggle-frame-fullscreen)
(global-set-key (kbd "C-l") 'goto-line)


;; - UTILITIES

(use-package helm
  :ensure t
  :config (progn
	    (helm-mode 1)
	    (global-set-key (kbd "C-c s") 'hs-show-all)
	    (global-set-key (kbd "C-c h") 'hs-hide-all)
	    (global-set-key (kbd "C-c TAB") 'hs-toggle-hiding)
	    (global-set-key (kbd "M-x") #'helm-M-x)
	    (global-set-key (kbd "C-x b") 'helm-mini)
	    (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
	    (global-set-key (kbd "C-x C-f") #'helm-find-files)
	    (global-set-key (kbd "C-c p f") #'helm-projectile-find-file)
	    (global-set-key (kbd "C-c p p") #'helm-projectile-switch-project)
	    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
	    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
	    (define-key helm-map (kbd "C-z")  'helm-select-action))) ; list actions using C-z)

(use-package projectile
  :ensure t
  :config (setq projectile-auto-discover t))

(use-package helm-projectile
  :ensure t
  :config (progn
	    (helm-projectile-on)
	    (global-set-key (kbd "C-c p f") #'helm-projectile-find-file)
	    (global-set-key (kbd "C-c p p") #'helm-projectile-switch-project))
  :after(helm projectile))

(use-package magit
  :ensure t
  :config (progn
	    (global-set-key (kbd "C-x g") 'magit)))
  
(use-package yasnippet
  :ensure t
  :config (yas-global-mode t))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; -- Autocompletion

(use-package company
  :ensure t
  :config (progn
	    (global-company-mode)))

(use-package git-link
  :ensure t)

;; - LANGUAGES

(use-package sqlformat
  :ensure t
  :config (progn)
    (setq sqlformat-command 'pgformatter)
    (setq sqlformat-args '("-s2" "-g"))
    (add-hook 'sql-mode-hook 'sqlformat-on-save-mode))
  

(use-package markdown-mode
  :ensure t
  :init
  (progn
    (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))))

;; -- Web mode and Typescript

(use-package tide
  :ensure t)

(use-package web-mode
  :after (tide flycheck)
  :ensure t
  :config (progn
	    (setq web-mode-code-indent-offset 2)
	    (defun setup-tide-mode ()
	      (interactive)
	      (tide-setup)
	      (flycheck-mode +1)
	      (setq flycheck-check-syntax-automatically '(save mode-enabled))
	      (eldoc-mode +1)
	      (local-set-key (kbd "M-.") 'tide-jump-to-definition)
	      (local-set-key (kbd "M-,") 'tide-jump-back)
	      (company-mode +1)
	      (tide-hl-identifier-mode +1))
	    (add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
	    (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
	    (add-to-list 'auto-mode-alist '("\\.ts\\'" . web-mode))
	    (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
	    (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
	    (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
	    (add-to-list 'auto-mode-alist '("\\.sass\\'" . web-mode))
	    (add-hook 'web-mode-hook
		      (lambda ()
			(when (or (string-equal "tsx" (file-name-extension buffer-file-name))
				  (string-equal "ts" (file-name-extension buffer-file-name)))
			  (setup-tide-mode))))))

;; -- Lisp

(use-package racket-mode
  :ensure t
  :config
  (progn
    (add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-mode))))

(use-package flycheck-clj-kondo
  :ensure t)

(use-package clojure-mode
  :ensure t
  :config
  (require 'flycheck-clj-kondo))

(use-package fira-code-mode
  :ensure t
  :custom (fira-code-mode-disabled-ligatures '("[]" "#{" "#(" "#_" "#_(" "x")) ;; List of ligatures to turn off
  :hook prog-mode) ;; Enables fira-code-mode automatically for programming major modes

(use-package cider
  :ensure t
  :after (company)
  :init (setq cider-show-error-buffer nil)
  :config (progn
	    ;; Disabling as was erroring. Should renable when investigated further.
	    (global-set-key (kbd "C-c c b") 'cider-repl-clear-buffer)
	    (define-key clojure-mode-map (kbd "C-c f") 'cider-format-buffer) ; rebind tab to run persistent action
	    (add-hook 'cider-repl-mode-hook #'company-mode)
	    (add-hook 'cider-mode-hook #'company-mode)))

(use-package clj-refactor
  :ensure t
  :after (clojure-mode cider)
  :config (progn
	    (defun my-clojure-mode-hook ()
	      (clj-refactor-mode 1)
	      (yas-minor-mode 1) ; for adding require/use/import statements
	      ;; This choice of keybinding leaves cider-macroexpand-1 unbound
	      (cljr-add-keybindings-with-prefix "C-c C-m"))
	    (add-hook 'clojure-mode-hook #'my-clojure-mode-hook)))

;; Rand

(use-package yaml-mode
  :ensure t)

(use-package terraform-mode
  :ensure t)

(use-package parinfer-rust-mode
  :ensure t
  :after (clojure-mode racket-mode)
  :config (progn
            (add-hook 'racket-mode-hook #'parinfer-rust-mode)
            (add-hook 'clojure-mode-hook #'parinfer-rust-mode)
            (add-hook 'emacs-lisp-mode-hook #'parinfer-rust-mode))
  :init
  (setq parinfer-rust-auto-download t))

(use-package prettier-js
  :ensure t
  :config (progn
	    (add-hook 'js-mode-hook 'prettier-js-mode)))

(use-package vlf
  :ensure t
  :config (progn
	    (require 'vlf-setup)))


;; - GENERATED Code

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#3F3F3F" "#CC9393" "#7F9F7F" "#F0DFAF" "#8CD0D3" "#DC8CC3" "#93E0E3" "#DCDCCC"])
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(compilation-message-face 'default)
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#657b83")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-enabled-themes '(zenburn))
 '(custom-safe-themes
   '("b77a00d5be78f21e46c80ce450e5821bdc4368abf4ffe2b77c5a66de1b648f10" "9e3ea605c15dc6eb88c5ff33a82aed6a4d4e2b1126b251197ba55d6b86c610a1" "efcecf09905ff85a7c80025551c657299a4d18c5fcfedd3b2f2b6287e4edd659" "57a29645c35ae5ce1660d5987d3da5869b048477a7801ce7ab57bfb25ce12d3e" "285d1bf306091644fb49993341e0ad8bafe57130d9981b680c1dbd974475c5c7" "00445e6f15d31e9afaa23ed0d765850e9cd5e929be5e8e63b114a3346236c44c" "4c56af497ddf0e30f65a7232a8ee21b3d62a8c332c6b268c81e9ea99b11da0d3" "3b8284e207ff93dfc5e5ada8b7b00a3305351a3fb222782d8033a400a48eca48" "f0b0416502d80b1f21153df6f4dcb20614b9992cde4d5a5688053a271d0e8612" "830877f4aab227556548dc0a28bf395d0abe0e3a0ab95455731c9ea5ab5fe4e1" "aff12479ae941ea8e790abb1359c9bb21ab10acd15486e07e64e0e10d7fdab38" "51ec7bfa54adf5fff5d466248ea6431097f5a18224788d0bd7eb1257a4f7b773" "75a8194e6aa3ef759e8512fb6149137e2ada5947a7424e4278c395e374835afe" "e6df46d5085fde0ad56a46ef69ebb388193080cc9819e2d6024c9c6e27388ba9" default))
 '(fci-rule-color "#383838")
 '(highlight-changes-colors '("#d33682" "#6c71c4"))
 '(highlight-symbol-colors
   '("#efe5da4aafb2" "#cfc5e1add08c" "#fe53c9e7b34f" "#dbb6d3c3dcf4" "#e183dee1b053" "#f944cc6dae48" "#d360dac5e06a"))
 '(highlight-symbol-foreground-color "#586e75")
 '(highlight-tail-colors
   '(("#eee8d5" . 0)
     ("#b3c34d" . 20)
     ("#6ccec0" . 30)
     ("#74adf5" . 50)
     ("#e1af4b" . 60)
     ("#fb7640" . 70)
     ("#ff699e" . 85)
     ("#eee8d5" . 100)))
 '(hl-bg-colors
   '("#e1af4b" "#fb7640" "#ff6849" "#ff699e" "#8d85e7" "#74adf5" "#6ccec0" "#b3c34d"))
 '(hl-fg-colors
   '("#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3"))
 '(hl-paren-colors '("#2aa198" "#b58900" "#268bd2" "#6c71c4" "#859900"))
 '(lsp-ui-doc-border "#586e75")
 '(nrepl-message-colors
   '("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3"))
 '(package-selected-packages
   '(terraform-mode yaml-mode flycheck-clj-kondo prettier-js solarized-theme zenburn-theme clj-refactor fira-code-mode magit helm-projectile projectile web-mode yasnippet yassnippet cider company company-mode use-package tide sqlformat racket-mode parinfer-rust-mode markdown-mode helm git-link exec-path-from-shell clojure-mode))
 '(pdf-view-midnight-colors '("#DCDCCC" . "#383838"))
 '(pos-tip-background-color "#eee8d5")
 '(pos-tip-foreground-color "#586e75")
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#eee8d5" 0.2))
 '(term-default-bg-color "#fdf6e3")
 '(term-default-fg-color "#657b83")
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   '((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3")))
 '(vc-annotate-very-old-color "#DC8CC3")
 '(weechat-color-list
   '(unspecified "#fdf6e3" "#eee8d5" "#a7020a" "#dc322f" "#5b7300" "#859900" "#866300" "#b58900" "#0061a8" "#268bd2" "#a00559" "#d33682" "#007d76" "#2aa198" "#657b83" "#839496"))
 '(xterm-color-names
   ["#eee8d5" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#073642"])
 '(xterm-color-names-bright
   ["#fdf6e3" "#cb4b16" "#93a1a1" "#839496" "#657b83" "#6c71c4" "#586e75" "#002b36"]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
