;;; questi poi andrò a metterli in altri package
;;; schema definition (an html schema, an svg schema, a dae schema, I dunno)
#|
lo schema includerà i tipi di tag, a ogni tag saranno associati flag quali :
- sono aperti o meno
- direttive di "pretty printing" (dove mettere i newline quando le stampi, opzionale, di default non mette nessun newline)
- TODO : check su che argomenti può avere / non avere
- TODO : check su che tipi di sottotag può avere / non avere
|#


(in-package :xmltags)

(defun should-print-p (elt)
  "we'd like to be able to write things like (ul (li \"hello\") (li \"world\")) in the templates, to keep the template synthax short, though, to allow this we must have a way to make the program decide \"should I print this or just evaluate it?\", ergo this function"
  (or (stringp elt)
      (numberp elt)
      (characterp elt)))

(defmacro deftag (name &key (closep nil)
			 (newline-after-open nil)
			 (newline-before-close nil)
			 (newline-after-close nil))
  (let ((tagname (string-downcase (symbol-name name))))
    (let ((opening-tag-open (format nil "<~A" tagname))
	  (opening-tag-close (if closep "/>" ">"))
	  (closing-tag (if closep "" (format nil "</~A>" tagname))))
      `(defmacro ,name (&rest body)
	 (multiple-value-bind (attributes children) (split-kwargs body)
	   `(progn
	      ;; opening tag
	      (xml-princ ,,opening-tag-open) 
	      ;; attributes
	      ;; when (costante) ottimizzato via dal compiler
	      (when ',attributes (xml-princ " "))
	      ,@(mapcar (lambda (attr-pair)
			  `(let ((key ,(car attr-pair))
				 (val ,(cdr attr-pair)))
			     (xml-format "~A = \"~A\"" key val)))
			attributes)
	      (xml-princ ,,opening-tag-close)
	      (when ,,newline-after-open (xml-newline))

	      ;; body
	      ,@(mapcar (lambda (child)
			  `(let ((sub ,child))
			     (when (should-print-p sub) (xml-princ sub))))
			children)

	      (when ,,newline-before-close (xml-newline))
	      (xml-princ ,,closing-tag)
	      (when ,,newline-after-close (xml-newline))))))))


#|
(defmacro with-tags (&key (schema *html-spec*)
		       (stream *standard-output*)
		     &rest body)
  (multiple-value-bind (_ tagbody) (split-kwargs body)
    `(macrolet ,(make-tag-macros schema)
       ,@body)))

(defun make-tag-macros (schema)
  (mapcar #'make-tag-macro schema))

|#
