;; Adding melpa to list of packages
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

;; Execute from shell so commands work on osx.
(use-package exec-path-from-shell
  :ensure t
  :init (progn (setq explicit-shell-file-name "/bin/zsh")
         (setq shell-file-name "/bin/zsh"))
  :config (progn
            (when (memq window-system '(mac ns x))
              (exec-path-from-shell-initialize))))


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

(use-package clojure-mode
  :ensure t)

(use-package cider
  :ensure t
  :after (company)
  :init (setq cider-show-error-buffer nil)
  :config (progn
	    (add-hook 'cider-repl-mode-hook #'company-mode)
	    (add-hook 'cider-mode-hook #'company-mode))
  )


(use-package parinfer-rust-mode
  :ensure t
  :after (clojure-mode racket-mode)
  :config (progn
            (add-hook 'racket-mode-hook #'parinfer-rust-mode)
            (add-hook 'clojure-mode-hook #'parinfer-rust-mode)
            (add-hook 'emacs-lisp-mode-hook #'parinfer-rust-mode))
  :init
  (setq parinfer-rust-auto-download t))


;; - GENERATED Code

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit helm-projectile projectile web-mode yasnippet yassnippet cider company company-mode use-package tide sqlformat racket-mode parinfer-rust-mode markdown-mode helm git-link exec-path-from-shell clojure-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
