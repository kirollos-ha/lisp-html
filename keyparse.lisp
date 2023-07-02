;;; tagbdy parsing
#|
that is, separating attributes (represented as &key args).
we'd like the tag children to be given in a &body argument for syntactic convenience
we'd also like to give tag attributes with a kwarg synthax, as it feels more natural 

this works rather horrendously with cltl2 argument parsing, so guess what,
we're making our own, because this is lisp, and we can
|#
(in-package :keyparse)

(defun maybe-first-kwarg (lst)
  "extracts (cons key val) it that's possible, returns nil otherwise"
  (and (keywordp (car lst))
       (consp (cdr lst)) ; has at least two elements (and proper list, no dots)
       (cons (string-downcase (symbol-name (car lst))) ; key
	     (cadr lst)))) ; val

(defun split-kwargs (body)
  "returns (values <kwargs> <body>) from a list (append <kwargs> <body>), kwargs are returned as an alist of (cons key val), where key and string are lists, all keys are lowercase, because caps locked html scares me and symbols are case insensitive"
  (let ((kwargs nil))
    (do ((lst body (cddr lst)))
	(())
      (let ((kwarg (maybe-first-kwarg lst)))
	(if kwarg
	    (push kwarg kwargs)
	    (return-from split-kwargs (values (nreverse kwargs) lst))))))); lst qui prima sine
