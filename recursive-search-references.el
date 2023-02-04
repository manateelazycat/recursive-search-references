;;; recursive-search-references.el --- Recursive search references

;; Filename: recursive-search-references.el
;; Description: Recursive search references
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2021, Andy Stewart, all rights reserved.
;; Created: 2021-11-27 10:50:57
;; Version: 0.1
;; Last-Updated: 2021-11-27 10:50:57
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/recursive-search-references
;; Keywords:
;; Compatibility: GNU Emacs 29.0.50
;;
;; Features that might be required by this library:
;;
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Recursive search references
;;

;;; Installation:
;;
;; Put recursive-search-references.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'recursive-search-references)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET recursive-search-references RET
;;

;;; Change log:
;;
;; 2021/11/27
;;      * First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require
(require 'cl-lib)
(require 'treesit)

;;; Code:

(defvar recursive-search-references-search-dir nil)
(defvar recursive-search-references-ignore-dir nil)

(defun recursive-search-references-get-match-nodes (query)
  (ignore-errors
    (mapcar #'(lambda (range)
                (treesit-node-at (car range)))
            (treesit-query-range
             (treesit-node-language (treesit-buffer-root-node))
             query))))

(defun recursive-search-references-match-times-in-directory (search-string)
  (- (recursive-search-references-search-in-directory search-string recursive-search-references-search-dir)
     (recursive-search-references-search-in-directory search-string recursive-search-references-ignore-dir)))

(defun recursive-search-references-search-in-directory (search-string search-dir)
  (let* ((search-command (format "rg -e %s %s --no-ignore -g '!node_modules' -g '!dist' --stats -q"
                                 (shell-quote-argument search-string)
                                 (shell-quote-argument search-dir)))
         (search-result (shell-command-to-string search-command))
         (match-times (string-to-number (nth 0 (split-string (nth 1 (split-string search-result "\n")))))))
    match-times))

(defun recursive-search-references-get-provide-name ()
  (save-excursion
    (when (search-forward-regexp "(provide\\s-'" nil t)
      (thing-at-point 'symbol t)
      )))

(defun recursive-search-references-function (match-times-func location)
  (interactive)
  (let* ((function-nodes (append
                          (recursive-search-references-get-match-nodes '((function_definition name: (symbol) @x)))
                          (recursive-search-references-get-match-nodes '((function_definition name: (identifier) @x)))
                          (recursive-search-references-get-match-nodes '((method_declaration name: (identifier) @x)))
                          (recursive-search-references-get-match-nodes '((function_declaration name: (identifier) @x)))
                          ))
         (function-names (mapcar #'treesit-node-text function-nodes))
         (provide-name (recursive-search-references-get-provide-name))
         (search-names (if provide-name
                           (append function-names (list provide-name))
                         function-names))
         (reference-functions (cl-remove-if #'(lambda (f) (<= (funcall match-times-func f) 1)) search-names)))

    (if (> (length reference-functions) 0)
        (progn
          (message "Found below reference functions in current %s." location)
          (message "--------")
          (mapcar #'(lambda (f) (message "%s" f)) reference-functions)
          (message "--------")
          (message "Found reference functions, switch to buffer `*Messages*' to review."))
      (message "No references found in directory %s, you can remove current extension safely." location))))

(defun recursive-search-references ()
  (interactive)
  (setq recursive-search-references-search-dir (expand-file-name (read-directory-name "Recursive search references at directory: ")))
  (setq recursive-search-references-ignore-dir (expand-file-name default-directory))
  (recursive-search-references-function 'recursive-search-references-match-times-in-directory "directory"))

(provide 'recursive-search-references)

;;; recursive-search-references.el ends here
