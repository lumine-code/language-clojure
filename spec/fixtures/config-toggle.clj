#_
(+ 1 2 3 (+ 4 5))
;  ^ constant.numeric
;         ^ entity.name.function

(comment 1 2 3)
;  ^ keyword.control
;        ^ comment.block

;; Namespace loading
(use '[foo.bar])
; ^ entity.name.function
; ^ !invalid.deprecated

(:use [foo.bar])
; ^ !invalid.deprecated

(ns other.namespace
  (:use [foo.bar]))
;   ^ !invalid.deprecated
