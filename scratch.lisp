(defstruct (tagspec
	    (:constructor tag))
  "tutto quello che il sistema sa di una tag viene dallo struct tag associato, tutto"
  ;; poi allo struct andaranno aggiunte, tra le altre cose
  ;; - check da fare sui parametri alla generazione
  ;; - "hint" per la stampa, ovvero dove mettere i newline
  ;; - vedi poi
  sym
  empty-p)

(defun tagspec-name (spec) (string-downcase (symbol-name (tagspec-sym spec))))

(defparameter *html-tags-spec* (list
			  (tag :sym 'h1 :empty-p nil)
			  (tag :sym 'h2 :empty-p nil)
			  (tag :sym 'h3 :empty-p nil)
			  (tag :sym 'h4 :empty-p nil)
			  (tag :sym 'h5 :empty-p nil)

			  (tag :sym 'p :empty-p nil)

			  (tag :sym 'ul :empty-p nil)
			  (tag :sym 'li :empty-p nil)
			  (tag :sym 'div :empty-p nil)

			  (tag :sym 'a :empty-p nil)

			  (tag :sym 'img :empty-p t)
			  (tag :sym 'br :empty-p t)))

(defun maybe-first-kwarg (lst)
  "got a bit too untestable to stay as a single labels preamble returns first key-arg pair it that's possible, nil otherwise"
  (and (keywordp (car lst))
       (consp (cdr lst))
       (cons (string-downcase (symbol-name (car lst)))
	     (cadr lst))))

(defun split-kwargs (body)
  "returns (values <kwargs> <body>) from a list (append <kwargs> <body>), kwargs are returned as an alist of (cons key val), where key and string are lists"
  (let ((kwargs nil))
    (do ((lst body (cddr lst)))
	(())
      (let ((kwarg (maybe-first-kwarg lst)))
	(if kwarg
	    (push kwarg kwargs)
	    (return-from split-kwargs (values (nreverse kwargs) lst))))))); lst qui prima sine

(defun should-print-p (elt)
  "should the value inserted in the tag be printed or evaluated without printing? (feature used to avoid littering the tag writing with prints and formats)"
  (or (stringp elt)
      (numberp elt)
      (characterp elt)))

(defmacro with-tag (tagname body &key
				   (opening-tag-open-fmt "<~a")
				   (opening-tag-close-fmt ">")
				   (closing-tag-open-fmt "</~a")
				   (closing-tag-close-fmt ">~%"))
  "generates code to print the tagbody inside of a <tagname> ... </tagname> element"
  (let ((childsym (gensym "child"))
	(keysym (gensym "key"))
	(valsym (gensym "val")))
    (multiple-value-bind (tag-attrs tag-body) (split-kwargs body)
      (print tag-attrs)
      (print tag-body)
      `(progn
	 (html-format ,opening-tag-open-fmt ,tagname)
	 ;; print tag attributes :
	 ;; using let allows us to have variable lookup be done at runtime
	 ;; thus using rutime values to be used in the generated html
	 ,@(mapcar (lambda (x)
		     `(let ((,keysym ,(car x))
			    (,valsym ,(cdr x)))
			(html-format " ~a=\"~a\"" ,keysym ,valsym)))
		   tag-attrs)
	 (html-format ,opening-tag-close-fmt)
	 ;; same construct as the tags
	 ,@(mapcar (lambda (x)
		     `(let ((,childsym ,x))
			(when (should-print-p ,childsym)
			  (html-format "~a" ,childsym))))
		   tag-body)
	 (html-format ,closing-tag-open-fmt ,tagname)
	 (html-format ,closing-tag-close-fmt)))))

(defmacro with-empty-tag (tagname body)
  "generates the code to print an \"empty\" <tagname (attr=something)*/> element"
  `(with-tag ,tagname ,body
     :opening-tag-close-fmt "/>~%"
     :closing-tag-open-fmt ""
     :closing-tag-close-fmt ""))

(defparameter *html-out-stream* nil)
(defparameter *default-html-out-stream* *standard-output*)
  
;; this one's a macro because i don't want to touch format's arglist
(defmacro html-format (&rest body) `(format *html-out-stream* ,@body))

(defmacro deftag (tag)
  (let ((tagname (string-downcase (symbol-name tag))))
    `(defmacro ,tag (&rest body) `(with-tag ,,tagname ,body))))

(defmacro def-empty-tag (tag)
  (let ((tagname (string-downcase (symbol-name tag))))
  `(defmacro ,tag (&rest body) `(with-empty-tag ,,tagname ,body))))

(defmacro with-tags (&rest body)
  `(let ((*html-out-stream* (or *html-out-stream* *default-out-stream*)))
     (macrolet ,(generate-tag-macrolets)
       ,@ body)))

(defun generate-tag-macrolets ()
  "uses *html-tags-spec* to create variable assignments for a macrolet that will put all tags in a local environment, as to not define h1, li, div, et al. globally when this code is used, and to avoid wirting (tags:ul (tags: li \"hello\") (tags:li \"world\")) when this goes in a sseparate package"
  (mapcar #'single-tag-macrolet-from-spec *html-tags-spec*))

(defun single-tag-macrolet-from-spec (spec)
  "generates a single assigment in the macrolet, using a single tagspec from the list, though the name might be un po' too much"
  (let ((tagname (tagspec-name spec)))
    `(,(tagspec-sym spec) (&rest body) `(,(if ,(tagspec-empty-p spec)
					      'with-empty-tag
					      'with-tag)
					 ,,tagname
					 ,body))))

#|
(defmacro maplet ())
;; sintassi questa
(maplet (((,keysym) ,(car x))
	 ((,valsym) ,(cdr x)))
	(format t "..." ,keysym ,valsym)
	tag-attrs)

;; dovrebbe espandersi a questa
(mapcar (lambda (x)
	  `(let ((,keysym ,(car x))
		 (,valsym ,(cdr x)))
	     (format t "~A=\"~A\"" ,keysym ,valsym)))
	tag-attrs)
|#
