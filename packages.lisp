(defpackage :keyparse
  (:use :cl :cl-user)
  (:export split-kwargs))

(defpackage :tagspec
  (:use :cl :cl-user)
  (:export
   spec
   ;; cazzo bello esportare una struct
   spec-name spec-closep
   spec-newline-after-open spec-newline-before-close spec-newline-after-close
   spec-attributes-check spec-body-check

   *html-spec*))

(defpackage :xmlprint
  (:use :cl :cl-user)
  (:export *xml-out-stream* xml-princ xml-format xml-newline))

(defpackage :xmltags
  (:use :cl :cl-user)
  (:import-from :keyparse split-kwargs)
  (:import-from :xmlprint xml-princ xml-format xml-newline)
  (:export deftag with-tags))
