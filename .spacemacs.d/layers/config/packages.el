;;; packages.el --- config layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Shunsuke KITADA <shunk031@OguraYuiMacbook.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `config-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `config/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `config/pre-init-PACKAGE' and/or
;;   `config/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst config-packages
  '(
    smart-newline
    import-popwin
    rainbow-mode
    color-identifiers-mode
    dimmer
    (frog-jump-buffer :location (recipe :fetcher github
                                        :repo "waymondo/frog-jump-buffer"))
    ;; for local settings
    (basic-config :location local)
    (c-c++-config :location local)
    (company-config :location local)
    (google-translate-config :location local)
    (helm-config :location local)
    (ispell-config :location local)
    (popwin-config :location local)
    (undo-tree-config :location local)
    (view-mode :location built-in)
    (display-line-number-mode :location built-in)
    )
)

(defun config/init-basic-config ()
  (use-package basic-config))

(defun config/init-c-c++-config ()
  (use-package c-c++-config
    :commands (clang-format)))

(defun config/init-color-identifiers-mode ()
  (use-package color-identifiers-mode
    :init
    (progn
      (spacemacs|diminish color-identifiers-mode "" "")
      (add-hook 'after-init-hook 'global-color-identifiers-mode))))

(defun config/init-company-config ()
  (use-package company-config
    :after (company)))

(defun config/init-dimmer ()
  (use-package dimmer
    :init
    (progn
      (setq dimmer-fraction 0.50)
      (setq dimmer-exclusion-regexp "^\*helm.*\\|^ \*Minibuf-.*\\|^ \*Echo.*")
      (dimmer-mode))))

(defun config/init-display-line-number-mode ()
  (dolist (hook '(prog-mode-hook))
    (add-hook hook 'display-line-numbers-mode)))

(defun config/init-frog-jump-buffer ()
 (use-package frog-jump-buffer
   :bind ("M-g f" . frog-jump-buffer)))

(defun config/init-google-translate-config ()
  (use-package google-translate-config
    :commands (google-translate-enja-or-jaen)))

(defun config/init-helm-config ()
  (use-package helm-config
    :after (helm helm-swoop ace-isearch)
    :commands (helm-swoop-nomigemo isearch-forward-or-helm-swoop)))

(defun config/init-ispell-config ()
  (use-package ispell-config))

(defun config/init-popwin-config ()
  (use-package popwin-config
    :after (popwin)))

(defun config/init-import-popwin ()
  (use-package import-popwin
    :after (popwin)))

(defun config/init-smart-newline ()
  (use-package smart-newline
    :init
    (dolist
        (hook
         '(
           markdown-mode-hook
           ))
      (add-hook hook
                (lambda ()
                  (smart-newline-mode 1))))))

(defun config/init-rainbow-mode ()
  (use-package rainbow-mode
    :init
    (progn
      (spacemacs|diminish rainbow-mode "" "")

      (dolist (hook '(css-mode-hook
                      scss-mode-hook
                      html-mode-hook
                      emacs-lisp-mode-hook
                      nxml-mode-hook
                      )
                    )
        (add-hook hook 'rainbow-mode)
        )
      )))

(defun config/init-undo-tree-config ()
  (use-package undo-tree-config
    :after (undo-tree)))

(defun config/init-view-mode ()
  (add-hook 'view-mode-hook
            '(lambda ()
               (progn
                 (define-key view-mode-map (kbd "h") 'backward-char)
                 (define-key view-mode-map (kbd "j") 'next-line)
                 (define-key view-mode-map (kbd "k") 'previous-line)
                 (define-key view-mode-map (kbd "l") 'forward-char)))))

;;; packages.el ends here
