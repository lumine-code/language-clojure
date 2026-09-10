;; Shared with the EDN grammar, whose scopes stay `.clojure` rather than
;; becoming `.edn`: that grammar claims no file types of its own and is only
;; ever reached by injection from `source.clojure`, which it adopts as its
;; language scope. Its tokens therefore always sit inside a Clojure file, and a
;; theme should not have to match two segments for one construct.

;; Collections
(vec_lit) @meta.vector.clojure
("[" @punctuation.section.vector.begin.clojure
  (#is? test.childOfType vec_lit)
  (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
("]" @punctuation.section.vector.end.clojure
  (#is? test.childOfType vec_lit))

(map_lit) @meta.map.clojure
("{" @punctuation.section.map.begin.clojure
  (#is? test.childOfType map_lit)
  (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
("}" @punctuation.section.map.end.clojure
  (#is? test.childOfType map_lit))

(set_lit) @meta.set.clojure
(["#" "{"] @punctuation.section.set.begin.clojure
  (#is? test.childOfType set_lit)
  (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
("}" @punctuation.section.set.end.clojure
  (#is? test.childOfType set_lit))

(meta_lit) @meta.metadata.clojure

((regex_lit) @string.regexp.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((sym_lit) @meta.symbol.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((kwd_lit) @constant.keyword.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
(("\"" @punctuation.definition.string.begin.clojure)
  (#is? test.childOfType str_lit)
  (#is? test.first true)
  (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
(("\"" @punctuation.definition.string.end.clojure)
  (#is? test.childOfType str_lit)
  (#is? test.last true)
  (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((str_lit) @string.quoted.double.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((num_lit) @constant.numeric.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((nil_lit) @constant.language.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((bool_lit) @constant.language.clojure (#is-not? test.descendantOfNodeWithData clojure.dismissTag))
((comment) @comment.line.semicolon.clojure
  (#set! adjust.endBeforeFirstMatchOf "\\r?\\n?$"))
((dis_expr)
 @comment.block.clojure
 (#is? test.config language-clojure.dismissTag)
 (#set! clojure.dismissTag true)
 (#set! capture.final true))

(ERROR) @invalid.illegal.clojure
