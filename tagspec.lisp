#|
per attributes check possiamo fare qualcosa come
- nil-attribute
- non-nil-attribute
- no-attributes
- some-attributes
- attribute-among-options
(
e creare una funzione helper che si vede lei la rappresentazione interna, boh.
Je ne sais pas 
|#
(in-package :tagspec)

(defstruct spec
  name
  closep
  newline-after-open
  newline-before-close
  newline-after-close
  attributes-check
  body-check)

(defmacro make-spec-short (name &key closep multiline)
  "shorthand for when newlines follow a predictable pattern (to be updated once I start taking the attrbute and body checks seriously)"
  (append `(make-spec :name ,name :closep ,closep)
	  (if multiline
	      '(:newline-after-open t
		:newline-before-close t
		:newline-after-close t)
	      '(:newline-after-open nil 
		:newline-before-close nil 
		:newline-after-close t))))

(defun make-spec-typeface (name)
  "italics, bold, strikethrough, all the same to me"
  (make-spec :name name
	     :closep nil
	     :newline-after-open nil 
	     :newline-before-close nil 
	     :newline-after-close nil))

(defparameter *html-spec*
  (list
   (make-spec-short "html" :closep nil :multiline t)
   (make-spec-short "head" :closep nil :multiline t)
   (make-spec-short "body" :closep nil :multiline t)
   (make-spec-short "script" :closep nil :multiline nil)
   (make-spec-short "link" :closep nil :multiline nil)

   (make-spec-short "h1" :closep nil :multiline t)
   (make-spec-short "h2" :closep nil :multiline t)
   (make-spec-short "h3" :closep nil :multiline t)
   (make-spec-short "h4" :closep nil :multiline t)
   (make-spec-short "ul" :closep nil :multiline t)
   (make-spec-short "li" :closep nil :multiline nil)

   (make-spec-short "div" :closep nil :multiline t)
   (make-spec-short "form" :closep nil :multiline t)))
			   
