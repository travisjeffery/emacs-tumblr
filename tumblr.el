;;; tumblr.el --- Post to Tumblr using its HTTP-based API

;; Copyright (c) 2008 Travis Jeffery
;; Time-stamp: 2008-10-05
;; Author: Travis Jeffery <eatsleepgolf@gmail.com>
;; Created: 16-07-08
;; Keywords: tumblr

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation version 2.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; For a copy of the GNU General Public License, search the Internet,
;; or write to the Free Software Foundation, Inc., 59 Temple Place,
;; Suite 330, Boston, MA 02111-1307 USA

;;; Commentary:

;; This is a set of interactive functions used to post to Tumblr.
;; This uses Tumblr's HTTP-based api.

;;;  Use:

;; Setup:

;;   M-x customize-group tumblr and change the variables to match your account.

;;   M-x tumblr-quick-post will allow you to make a quick post from the minibuffer
;;   M-x tumblr-buffer-post will take all the text from the current buffer and send that to Tumblr and will ask you for the title.
;;   M-x tumblr-start-post will create a new buffer and setup is up for you to post, to send the post when you are done use M-x tumblr-post

;;; Jupiter and Beyond the Finite

;; At the moment I'm content with just posting regular types as I use Tumblr as a blog, mainly. Also I think the other types are oriented for being in a browser anyway. So what I'm saying if is you want the other types code it yourself and post it on the site. And the same goes for reading posts (better suited for being in a broswer). Any improvements or advice is unwanted, even though my code is absolutely perfect in every way. There is not one recording of Travis Jeffery ever making a mistake, the problem is obviously attributed to your own error.

;;; Code

(require 'http-post-simple)

;;;;;;;;;;;;;;;;
;;; Variables
;;;;;;;;;;;;;;;;

(defvar tumblr-version-number "0.1.2")

;;;;;;;;;;;;;;;;;;;;;
;; Customizable Group
;;;;;;;;;;;;;;;;;;;;;

(defgroup tumblr nil
  "tumblr.el customizations."
  :version "0.1"
  :group 'tumblr)

(defcustom tumblr-email
  ""
  "Your user name associated with your tumblr account."
  :group 'tumblr
  :type 'string)

(defcustom tumblr-password
  ""
  "Your password for your tumblr account."
  :group 'tumblr
  :type 'string)

(defcustom tumblr-default-type
  "regular"
  "The default type of post."
  :group 'tumblr
  :type 'string)

(defcustom tumblr-post-url
  "http://www.tumblr.com/api/write"
  "The url that tumblr uses to receive posts."
  :group 'tumblr
  :type 'string)

;;;;;;;;;;

(defconst tumblr-success-msg "Post sent successfully.")

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions To Send Posts
;;;;;;;;;;;;;;;;;;;;;;;;;

                                        ; (http-post url parameters content-type &optional headers sentinel version verbose bufname)
(defun send-post (title body)
  "DRY function to send post."
  (http-post-simple tumblr-post-url (list (cons 'email  tumblr-email)
                                          (cons 'password  tumblr-password)
                                          (cons 'type  tumblr-default-type)
                                          (cons 'title  title)
                                          (cons 'body  body))
                    'utf-8))

(defun tumblr-post ()
  "Function used after you've created the template with tumblr-start-post and finished writing your post. Make sure you have set the variables in the tumblr customize-group."
  (interactive)
  (let ((title (when (string-match "TITLE:\\(\.\*\$\\)" (buffer-string)) (match-string 1 (buffer-string))))
        (body (buffer-substring ((lambda () (goto-line 3) (point))) (point-max))))
    (send-post title body)))

(defun tumblr-quick-post ()
  "Posts to Tumblr by querying for both the title and body. Good for 1-2 liner posts."
  (interactive)
  (let ((title (read-string "TITLE: "))
        (body (read-string "Body: ")))
    (send-post title body)))

(defun tumblr-buffer-post ()
  "Posts to Tumblr by taking the entire current buffer as the body and queries for the title."
  (interactive)
  (let ((title (read-string "TITLE: "))
        (body (copy-all)))
    (send-post title body)))

(defun tumblr-start-post ()
  "Opens up a new buffer and inserts the text needed to send the post correctly to Tumblr."
  (interactive)
  (switch-to-buffer "*tumblr-post*")
  (auto-fill-mode 1)             ; I can go for a while on a single line
  (flyspell-mode)              ; for momentary lapses in spelling
  (nxhtml-mode)
  (insert "TITLE:
---BODY BEGINS BELOW THIS LINE---")
  (auto-fill-mode 1)             ; I can go for a while on a single line
  (flyspell-mode)
  )


(defun tumblr-region-post (beg end)
  (interactive (list (point) (mark)))
  (let ((title (read-string "TITLE: ")) (body (buffer-substring beg end)))
    (send-post title body)))

(provide 'tumblr)
