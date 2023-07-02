(in-package :cl-user)

(defmacro paragraph (name)
  `(xmltags:deftag ,name 
    :closep nil 
    :newline-after-open t 
    :newline-before-close t 
    :newline-after-close t))
(defmacro title (name)
  `(oneline ,name))
(defmacro oneline (name)
  `(xmltags:deftag ,name 
    :closep nil 
    :newline-after-open nil 
    :newline-before-close nil 
    :newline-after-close t))
(defmacro facetag (name)
  `(xmltags:deftag ,name 
    :closep nil 
    :newline-after-open nil 
    :newline-before-close nil 
    :newline-after-close nil))
(paragraph html)
(paragraph head)
(paragraph body)
(paragraph p)

(paragraph ul)
(paragraph div)

(title h1)
(title h2)
(title h3)
(title h4)
(title h4)

(oneline li)
(oneline script)
(oneline link)
(oneline meta)
(oneline title)

;; ros launch files
(paragraph launch)
(paragraph node)
(xmltags:deftag param :closep t :newline-after-close t)

(defun ref (key env &key (test #'string=))
  "rendering contexts might have to be defined in some more efficient manner later"
  (cdr (assoc key env :test test)))

(defun template (&key env template-body)
  (html
   (head
    (meta :charset (or (ref "charset" env) "utf-8"))
    (title (or (ref "title" env) "titolo di default")))
   (body
    (cond ((functionp template-body) (funcall template-body))
	  (t template-body)))))

#|
note per poi
fille mi and company dovrebbero trovarsi in un env
la cosa dell'(if functionp else) si potrebbe fare nel ref
poi devo capire come "astrarre" il fatto che nell'utilizzo come dati probabile le renderizzo a stringhe
altrimenti potrebbe boh
faccio che tutte le "liste" o letterali composti vengono interpretati come lambda?
non vorrei dover specificare esplicitamente "questo lo renderizzi a stringa qui"
non sembra un'ottima cosa, almeno non per l'"astrazione"

potrei fare che "è esplicito" che stia chiamando una funzione o meno, e che la funzione poi potrebbe anche renerizzare qualcosa, je ne sais pas

l'idea sarebbe mettere questa cosa fino al punto in cui posso buttarla malamaente sul branch di big-rewrite e amen

quindi un po' di sforzi sulla feature parity con il frankenstein di prima, che dovrebbero già esserci (salvo with-tag, copialo, boh)
o anche prima, rinomina qualche pacchetto a qualcosa di normale, vedi che gira tutto, bellino bellino, sparalo su github, buttalo in qualche chat, chiedi come cazzo è, e prega

vedi di fare un readme per questa roba poi, e licenza gplv2, perchè non so la gplv3 che cambia, dovrei leggerla, magari agpl per rompere il cazzo a qualcuno
|#
