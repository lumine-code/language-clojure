;; Shared with the EDN grammar, whose scopes stay `.clojure` rather than
;; becoming `.edn`: that grammar claims no file types of its own and is only
;; ever reached by injection from `source.clojure`, which it adopts as its
;; language scope. Its tokens therefore always sit inside a Clojure file, and a
;; theme should not have to match two segments for one construct.

;; Collections
(vec_lit
 "[" @punctuation.section.vector.begin.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
 "]" @punctuation.section.vector.end.clojure)
@meta.vector.clojure

(map_lit
 "{" @punctuation.section.map.begin.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
 "}" @punctuation.section.map.end.clojure)
@meta.map.clojure

(set_lit
 ("#" "{") @punctuation.section.set.begin.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
 "}" @punctuation.section.set.end.clojure)
@meta.set.clojure

(meta_lit) @meta.metadata.clojure

((regex_lit) @string.regexp.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((sym_lit) @meta.symbol.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((kwd_lit) @constant.keyword.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
(str_lit
  "\"" @punctuation.definition.string.begin.clojure
  (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
  (#is? test.first))
(str_lit
  "\"" @punctuation.definition.string.end.clojure
  (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
  (#is? test.last))
((str_lit) @string.quoted.double.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((num_lit) @constant.numeric.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((nil_lit) @constant.language.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))
((bool_lit) @constant.language.clojure (#is-not? test.descendantOfNodeWithData clojure.dismissTag))
(comment) @comment.line.semicolon.clojure
((dis_expr)
 @comment.block.clojure
 (#is? test.config language-clojure.dismissTag)
 (#set! clojure.dismissTag true)
 (#set! capture.final true))

(ERROR) @invalid.illegal.clojure
