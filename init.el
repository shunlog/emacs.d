;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents 't)


;; Install use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)


;;;;;;;;;;;;;;;;;;;;;;;;
;;    Fonts and Theme ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :custom
  
  (frame-resize-pixelwise t)
  
  :config
  (let ((font-name "JetBrainsMono Nerd Font")
        (height (if (eq system-type 'darwin) 162 100)))
    (set-face-attribute 'default nil :family font-name :height height)
    (set-face-attribute 'fixed-pitch nil :family font-name :height height))

  (let ((font-name "Source Sans Pro")
        (height (if (eq system-type 'darwin) 180 108)))
    (set-face-attribute 'variable-pitch nil :family font-name :height height))

  
  (require-theme 'modus-themes) ; `require-theme' is ONLY for the built-in Modus themes
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-headings
        '((0 . (1.5))
          (1 . (1.4))
          (2 . (1.3))
          (3 . (1.2))
          (4 . (1.1))))

  ;; Make comments stand out
  (setq modus-themes-common-palette-overrides
        '((comment red-intense)))
  (custom-set-faces
   '(olivetti-fringe ((t :inherit default :background unspecified))))

  (require 'org)
  ;; Distinguish org link types
  (modus-themes-with-colors
    (org-link-set-parameters
     "id"
     :face `(:foreground ,green :underline t)))
  
  ;; ;; You can pick a preset palette for a change:
  ;; (setq modus-themes-common-palette-overrides
  ;;       modus-themes-preset-overrides-intense)

  ;; Load the theme of your choice.
  (load-theme 'modus-vivendi-tinted :no-confirm)
  )

;; Theme for org
(use-package org
  :config
  ;; Distinguish org link types
  (modus-themes-with-colors
    (org-link-set-parameters
     "id"
     :face `(:foreground ,green :underline t))))



;;;;;;;;;;;;;;;;;;;;
;; Default config ;;
;;;;;;;;;;;;;;;;;;;;


(use-package emacs
  :custom
  ;; Ignore case in completion systems
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-ignore-case t)
  
  (org-return-follows-link 't)

  ;; Use TAB instead of M-TAB for completion.
  (tab-always-indent 'complete)

  (tab-width 4)

  ;; Keep backup and auto-save files in /tmp
  (backup-directory-alist
   `((".*" . ,temporary-file-directory)))
  (auto-save-file-name-transforms
   `((".*" ,temporary-file-directory t)))

  :config
  (delete-selection-mode t)
  (scroll-bar-mode t)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  
  ;; bind-keys* prevents other modes from overriding these bindings
  (bind-keys*
   ;; Window management
   ("C-S-<right>" . windmove-right)
   ("C-S-<left>" . windmove-left)
   ("C-S-<up>" . windmove-up)
   ("C-S-<down>" . windmove-down)
   ("C-M-S-<right>" . windmove-swap-states-right)
   ("C-M-S-<left>" . windmove-swap-states-left)
   ("C-M-S-<up>" . windmove-swap-states-up)
   ("C-M-S-<down>" . windmove-swap-states-down)

   ;; macOS
   ;; on macos, GUI back/forward are not there,
   ;; but on firefox it's command-[ and command-]
   ("s-[" . previous-buffer)
   ("s-]" . next-buffer)
   

   ;; word movement
   ("M-F" . forward-to-word)
   ("M-B" . backward-to-word)
   )

  (add-to-list 'auto-mode-alist '("\\.ts[mx]?\\'" . typescript-ts-mode))

  (when (eq system-type 'darwin)
    (setq insert-directory-program "gls"))
    
  :bind
  ;; Buffers
  ("C-x C-b" . #'ibuffer)
  ;; Jump to file shortcuts, faster than bookmarks (e.g. init.el)
  ("C-c j c" . (lambda () (interactive)
				 (find-file-other-frame (file-name-concat user-emacs-directory "init.el"))))
  )

;;;;;;;;;;;;;;;;;
;; My packages ;;
;;;;;;;;;;;;;;;;;

(use-package toggle-split
  :load-path "my-packages/toggle-split"
  :bind
  (("C-x w t" . #'toggle-window-split)))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Built-in packages   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flyspell-mode
  :hook
  (text-mode .  flyspell-mode))


(use-package flymake
  :bind
  (("M-n" . #'flymake-goto-next-error)
   ("M-p" . #'flymake-goto-prev-error)))


(use-package winner
  :config
  (winner-mode))


(use-package view
  :ensure t
  :bind (("<next>" . #'View-scroll-half-page-forward)
         ("<prior>" . #'View-scroll-half-page-backward)
         ("C-S-n" . #'scroll-up-line)
         ("C-S-p" . #'scroll-down-line))
  :config
  ;; Don't let precision-mode override the <next> and <prior> binds
  (add-hook 'pixel-scroll-precision-mode-hook
            (lambda ()
              (when pixel-scroll-precision-mode
                (define-key pixel-scroll-precision-mode-map [next] #'View-scroll-half-page-forward)
                (define-key pixel-scroll-precision-mode-map [prior] #'View-scroll-half-page-backward)))))


(use-package dired
  :custom
  (dired-dwim-target t)
  (dired-listing-switches "-alh --group-directories-first"))


; taken from https://github.com/mickeynp/combobulate
(use-package treesit
  :mode (("\\.tsx\\'" . tsx-ts-mode))
  :preface
  (defun mp-setup-install-grammars ()
    "Install Tree-sitter grammars if they are absent."
    (interactive)
    (dolist (grammar
             '((css . ("https://github.com/tree-sitter/tree-sitter-css" "v0.20.0"))
               (html . ("https://github.com/tree-sitter/tree-sitter-html" "v0.20.1"))
               (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "v0.20.1" "src"))
               (json . ("https://github.com/tree-sitter/tree-sitter-json" "v0.20.2"))
               (python . ("https://github.com/tree-sitter/tree-sitter-python" "v0.20.4"))
               (toml "https://github.com/tree-sitter/tree-sitter-toml")
               (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src"))
               (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src"))
               (yaml . ("https://github.com/ikatyang/tree-sitter-yaml" "v0.5.0"))
               (go "https://github.com/tree-sitter/tree-sitter-go")))
      (add-to-list 'treesit-language-source-alist grammar)
      ;; Only install `grammar' if we don't already have it
      ;; installed. However, if you want to *update* a grammar then
      ;; this obviously prevents that from happening.
      (unless (treesit-language-available-p (car grammar))
        (treesit-install-language-grammar (car grammar)))))

  ;; Optional, but recommended. Tree-sitter enabled major modes are
  ;; distinct from their ordinary counterparts.
  ;;
  ;; You can remap major modes with `major-mode-remap-alist'. Note
  ;; that this does *not* extend to hooks! Make sure you migrate them
  ;; also
  (dolist (mapping
           '((python-mode . python-ts-mode)
			 (css-mode . css-ts-mode)
			 (typescript-mode . typescript-ts-mode)
			 (js2-mode . js-ts-mode)
			 (bash-mode . bash-ts-mode)
			 (css-mode . css-ts-mode)
			 (json-mode . json-ts-mode)
			 (js-json-mode . json-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))
  :config
  (mp-setup-install-grammars))


(use-package flycheck
  :preface
  
  (defun mp-flycheck-eldoc (callback &rest _ignored)
    "Print flycheck messages at point by calling CALLBACK."
    (when-let ((flycheck-errors (and flycheck-mode (flycheck-overlay-errors-at (point)))))
      (mapc
       (lambda (err)
         (funcall callback
           (format "%s: %s"
                   (let ((level (flycheck-error-level err)))
                     (pcase level
                       ('info (propertize "I" 'face 'flycheck-error-list-info))
                       ('error (propertize "E" 'face 'flycheck-error-list-error))
                       ('warning (propertize "W" 'face 'flycheck-error-list-warning))
                       (_ level)))
                   (flycheck-error-message err))
           :thing (or (flycheck-error-id err)
                      (flycheck-error-group err))
           :face 'font-lock-doc-face))
       flycheck-errors)))

  (defun mp-flycheck-prefer-eldoc ()
    (add-hook 'eldoc-documentation-functions #'mp-flycheck-eldoc nil t)
    (setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
    (setq flycheck-display-errors-function nil)
    (setq flycheck-help-echo-function nil))

  
  :hook
  ;; Eldoc messages in the echo area overwrite the flycheck errors,
  ;; this merges them
  ;; https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc
  ((flycheck-mode . mp-flycheck-prefer-eldoc)))


(use-package eglot
  :preface
  (defun mp-eglot-eldoc ()
    (setq eldoc-documentation-strategy
          'eldoc-documentation-compose-eagerly))
  ;; Make eglot echo area messages play nice with Eldoc, the echo area arbiter
  ;; https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc
  :hook
  ((eglot-managed-mode . mp-eglot-eldoc)))


(use-package org
  :hook
  (org-mode . variable-pitch-mode)
  (org-mode . visual-line-mode)
  
  :custom
  (org-cite-global-bibliography (list (file-truename "~/org/bibliography/global.bib")))
  (org-image-actual-width (list 500))
  (org-edit-src-content-indentation 0)
  ;; Fold property drawers
  (org-startup-folded 'nofold)
  
  :config

  ;; My genius solution for trusting my org files!
  ;; could generalize it to setting any local variables based on file path
  (defun org-confirm-evaluate-disable ()
    (interactive)
    "Disable confirmation dialog on evaluating code blocks if inside org directory."
    (condition-case nil
        (let* ((safe-directories `(,org-directory "~/uni/"))
              (inside-safe-dir
               (cl-some (lambda (dir-path)
                          (string-prefix-p (expand-file-name dir-path)
                                           (file-name-directory buffer-file-name)))
                        safe-directories)))
          (if inside-safe-dir
              (setq-local org-confirm-babel-evaluate nil)))))
  (add-hook 'find-file-hook #'org-confirm-evaluate-disable)

  ;; We use variable-pitch mode in org,
  ;; but some things should to stay in fixed-pitch:
  (set-face-attribute 'org-block nil            :foreground 'unspecified :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil             :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil         :inherit '(shadow fixed-set))
  (set-face-attribute 'org-special-keyword nil  :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil        :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil         :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil            :inherit 'fixed-pitch)

  ;; Increase the size of the Latex previews
  (plist-put org-format-latex-options :scale 1.5)
  
  )


;; Org-indent has 2 disadvantages:
;; 1. (genrally) Wastes horizontal space
;; 2. doesn't work with org-modern's code block fringes
;; But just in case I'll ever want to give it another try:
;; (use-package org-indent
;;   :config
;;   (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch)))

;;;;;;;;;;;;;;;;;;;;;;;
;; External packages ;;
;;;;;;;;;;;;;;;;;;;;;;;


; Vertical minibuffer
(use-package vertico
  :ensure t
  :init
  (vertico-mode))


(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))


(use-package vertico-mouse
  :after vertico
  :ensure nil
  :init
  (vertico-mouse-mode))


;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))


; Preview matches, lines, buffers, themes, etc. before selecting them in the mini-buffer
(use-package consult
  :ensure t
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("C-:" . consult-register-load)
         ("C-;" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode))


; Add fuzzy search
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))


; pop-up completion
(use-package corfu
  :ensure t
  :demand t
  :custom
  ;; Make sure this matches the variable `orderless-component-separator`
  (corfu-separator ?\s)
  (corfu-preview-current nil) ;; Disable current candidate preview
  :bind
  (:map corfu-map
	;; Make TAB expand common prefix instead of selecting 
        ("TAB" . corfu-expand)
        ([tab] . corfu-expand))
  :config
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)
  ;; Enable expanding to the common candidate prefix with TAB
  ;; when using the Orderless completion style
  (add-to-list 'completion-styles-alist
               '(tab completion-basic-try-completion ignore
		     "Completion style which provides TAB completion only."))
  (setq completion-styles '(tab orderless basic))
)


;; Add rich annotations to the completion minibuffers
(use-package marginalia
  :ensure t
   :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))


;; Like a right-click contextual menu but in a minibuffer
(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("M-." . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  )

;; Enable embark export from consult edit buffers~
;; consult-line -> embark-export to occur-mode buffer -> occur-edit-mode for editing of matches in buffer.
;; consult-grep -> embark-export to grep-mode buffer -> wgrep for editing of all matches.
;; consult-find -> embark-export to dired-mode buffer -> wdired-change-to-wdired-mode for editing.
(use-package embark-consult
  :ensure t
  :after (:all embark consult))


(use-package bookmark-view
  :ensure t)


(use-package magit
  :ensure t)


;; My workflow:
;; 1. Use consult-grep (or better consult-ripgrep) to write the query
;; 2. Use embark-export ("C-. E") to get the grep buffer
;; 3. Enter wgrep mode with "C-c C-p"
(use-package wgrep
  :ensure t)


(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))


(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode . enable-paredit-mode)
	 (eval-expression-minibuffer-setup . enable-paredit-mode)
	 (ielm-mode . enable-paredit-mode)
	 (lisp-mode . enable-paredit-mode)
	 (lisp-interaction-mode . enable-paredit-mode)
	 (scheme-mode . enable-paredit-mode)
	 (racket-mode . enable-paredit-mode)
	 (racket-repl-mode . enable-paredit-mode)
	 ;; (geiser-repl-mode . enable-paredit-mode))
         )
  :bind
  (:map paredit-mode-map
	;; remove stupid bindings that conflict with REPLs: https://www.racket-mode.com/#paredit
	("RET" . nil)
	("C-j" . nil)
	("C-m" . nil)
	;; Square parens
	("M-[" . paredit-wrap-square)
	;; C-BSP should be same as M-BSP
	("C-<backspace>" . paredit-backward-kill-word)
	;; Don't shadow M-s map, it has many search functions
	("M-s" . nil)
	("M-S" . nil)))


;; Set margins and width of text content 
(use-package olivetti
  :ensure t
  :hook (org-mode . olivetti-mode)
  :custom
  (olivetti-body-width 65)
)


(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :custom
  ;; Use circle symbols instead of triangles
  (org-modern-star 'replace)
  ;; They are different sizes anyway,
  ;; and the hollow triangles don't look good when small
  (org-modern-fold-stars '(("⯈" . "⯆")
                           ("⯈" . "⯆")
                           ("⯈" . "⯆")
                           ("⯈" . "⯆")
                           ("⯈" . "⯆"))))


(use-package org-download
  :ensure t
  :custom
  (org-download-image-dir "./img")
  (org-download-heading-lvl 0))


(use-package org-roam
  :after org
  :demand t
  :ensure t
  :hook (org-roam-mode . variable-pitch-mode)
  (org-roam-mode . visual-line-mode)
  
  :custom
  
  (org-roam-directory (file-truename "~/org"))
  (org-roam-dailies-directory (file-truename "~/org/journal"))
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-capture-templates
   '(("i" "idea" plain "%?"
      :if-new (file+head "ideas/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :immediate-finish t
      :unnarrowed t)
     ("b" "bibliography" plain "%?"
      :if-new
      (file+head "bibliography/%<%Y%m%d%H%M%S>-${title}.org" "#+title: ${title}\n")
      :immediate-finish t
      :unnarrowed t)
     ("w" "wiki" plain "%?"
      :if-new (file+head "wiki/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :immediate-finish t
      :unnarrowed t)
     ("a" "agenda" plain "%?"
      :if-new (file+head "agenda/${slug}.org" "#+title: ${title}\n")
      :immediate-finish t
      :unnarrowed t)
     ("A" "article" plain "%?"
      :if-new
      (file+head "articles/%<%Y%m%d%H%M%S>-${title}.org" "#+title: ${title}\n#+filetags: :article:\n")
      :immediate-finish t
      :unnarrowed t)))
  
  :bind (("C-c n b" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
		 ("C-c n t" . org-roam-dailies-find-today)
		 ("C-c n j" . org-roam-dailies-capture-today)
		 ("C-c n d" . org-roam-dailies-goto-date))

  :config
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol)
  ;; Get `org-roam-preview-visit' and friends to replace the main window. This
  ;;should be applicable only when `org-roam-mode' buffer is displayed in a
  ;;side-window.
  ;; (add-hook 'org-roam-mode-hook
  ;;           (lambda ()
  ;;             (setq-local display-buffer--same-window-action
  ;;                         '(display-buffer-use-some-window
  ;;                           (main)))))


  ;; Display only the paragraph around the back-link in the org-roam buffer,
  ;; instead of the entire file.
  (defun my/preview-fetcher ()
    (let* ((elem (org-element-context))
           (parent (org-element-property :parent elem)))
      ;; TODO: alt handling for non-paragraph elements
      (string-trim-right (buffer-substring-no-properties
                          (org-element-property :begin parent)
                          (org-element-property :end parent)))))
  (setq org-roam-preview-function #'my/preview-fetcher)

  ;; Display org-roam buffer in a side window
  (add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))
  ;; And open file links in the current window (to not overwrite the roam buffer)
  (setq org-link-frame-setup
      '((file . find-file)))  ;; Ensures links open in the current window
  
  )


(use-package pulsar
  :ensure t
  :config
  (pulsar-global-mode 't)
  (add-to-list 'pulsar-pulse-functions #'View-scroll-half-page-forward)
  (add-to-list 'pulsar-pulse-functions #'View-scroll-half-page-backward))


;; Read ePub files
(use-package nov
  :ensure t
  :demand t
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))


(use-package ox-hugo
  :ensure t
  :pin melpa
  :after ox)

;;;;;;;;;;;;;;;
;; Languages ;;
;;;;;;;;;;;;;;;

(use-package python
  :config
  (if (executable-find "ipython")
    (setq python-shell-interpreter "ipython"
          python-shell-interpreter-args "-i --simple-prompt")
    (message "Warning: ipython not found in PATH. Using default python REPL."))
)


;; Format python files on save
(use-package py-autopep8
  :ensure t
  :hook
  ((python-ts-mode) . py-autopep8-mode)
  ((python-mode) . py-autopep8-mode))


(use-package nodejs-repl
  :ensure t)


(use-package hledger-mode
  :ensure t
  :demand t
  :mode "\\hledger.journal\\'"
  :custom
  (hledger-currency-string "MDL"))


(use-package racket-mode
  :ensure t
  :custom
  (racket-documentation-search-location "file:///usr/share/doc/racket/search/index.html?q=%s")
  :hook
  (racket-mode . racket-xp-mode)
  (racket-repl-mode . (lambda () (setq truncate-lines t)))
  :bind
  (:map racket-xp-mode-map
        ("<f5>" . racket-run)
	    ("C-M-S-p" . racket-xp-previous-use)
	    ("C-M-S-n" . racket-xp-next-use)))


;; Common Lisp
(use-package slime
  :ensure t
  :config
  (setq inferior-lisp-program "/usr/bin/sbcl"))


;; Golang
(use-package go-mode
  :ensure t)


;; Erlang mode is loaded from local installation of Erlang
;; https://adoptingerlang.org/docs/development/setup/#emacs
(use-package erlang
  :load-path (lambda () (if (eq system-type 'darwin)
                            (file-expand-wildcards "/usr/local/lib/erlang/lib/tools*/emacs")
                            (file-expand-wildcards "/usr/lib/erlang/lib/tools*/emacs")))
  :mode (("\\.erl?$" . erlang-mode)
         ("rebar\\.config$" . erlang-mode)
         ("relx\\.config$" . erlang-mode)
         ("sys\\.config\\.src$" . erlang-mode)
         ("sys\\.config$" . erlang-mode)
         ("\\.config\\.src?$" . erlang-mode)
         ("\\.config\\.script?$" . erlang-mode)
         ("\\.hrl?$" . erlang-mode)
         ("\\.app?$" . erlang-mode)
         ("\\.app.src?$" . erlang-mode)
         ("\\Emakefile" . erlang-mode)))


;;;;;;;;;;;;
;; Custom ;;
;;;;;;;;;;;;


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-interval 0.4)
 '(bookmark-save-flag 1)
 '(comint-input-ignoredups t)
 '(comint-process-echoes t)
 '(confirm-kill-emacs 'yes-or-no-p)
 '(custom-safe-themes
   '("2e7dc2838b7941ab9cabaa3b6793286e5134f583c04bde2fba2f4e20f2617cf7"
     "712dda0818312c175a60d94ba676b404fc815f8c7e6c080c9b4061596c60a1db"
     "fbf73690320aa26f8daffdd1210ef234ed1b0c59f3d001f342b9c0bbf49f531c"
     default))
 '(electric-pair-mode t)
 '(find-file-visit-truename t)
 '(go-ts-mode-indent-offset 4)
 '(ibuffer-saved-filter-groups '(("dired" ("Dired" (used-mode . dired-mode)))))
 '(ibuffer-saved-filters
   '(("nestjs-demo-api"
      (or (mode . json-mode) (mode . typescript-ts-mode))
      (filename . "nestjs"))
     ("programming"
      (or (derived-mode . prog-mode) (mode . ess-mode)
          (mode . compilation-mode)))
     ("text document"
      (and (derived-mode . text-mode) (not (starred-name))))
     ("TeX"
      (or (derived-mode . tex-mode) (mode . latex-mode)
          (mode . context-mode) (mode . ams-tex-mode)
          (mode . bibtex-mode)))
     ("web"
      (or (derived-mode . sgml-mode) (derived-mode . css-mode)
          (mode . javascript-mode) (mode . js2-mode)
          (mode . scss-mode) (derived-mode . haml-mode)
          (mode . sass-mode)))
     ("gnus"
      (or (mode . message-mode) (mode . mail-mode)
          (mode . gnus-group-mode) (mode . gnus-summary-mode)
          (mode . gnus-article-mode)))))
 '(indent-tabs-mode nil)
 '(isearch-wrap-pause 'no)
 '(ispell-dictionary "en_US")
 '(ispell-personal-dictionary "~/aspell.pws")
 '(org-babel-load-languages '((python . t) (emacs-lisp . t)))
 '(org-pretty-entities t)
 '(package-selected-packages
   '(nerd-icons olivetti org-modern macrostep slime eglot go-mode ox-hugo
                py-autopep8 nov pulsar nodejs-repl bookmark-view
                embark-consult wgrep org-download embark marginalia
                hledger-mode vertico-mouse magit corfu orderless
                consult vertico expand-region use-package org-roam
                evil-org))
 '(pixel-scroll-precision-interpolate-page nil)
 '(pixel-scroll-precision-interpolation-factor 2.0)
 '(pixel-scroll-precision-mode t)
 '(safe-local-variable-values
   '((eval let ((font-name "Indie Flower"))
           (if (member font-name (font-family-list))
               (face-remap-add-relative 'default :height 130 :family
                                        font-name)
             (message "Couldn't load font")))
     (eval face-remap-add-relative 'default :family "Noto Serif")
     (eval face-remap-add-relative 'default :height 1.3 :family
           "Noto Serif")))
 '(sentence-end-double-space nil)
 '(typescript-ts-mode-indent-offset 2)
 '(visible-bell t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(olivetti-fringe ((t :inherit default :background unspecified))))
(put 'scroll-left 'disabled nil)
