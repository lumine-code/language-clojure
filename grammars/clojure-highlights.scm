;; "Special" things
(list_lit
  "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData clojure.dismissTag)
  .
  (sym_lit) @storage.control.clojure (#eq? @storage.control.clojure "do"))

(list_lit
  "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData clojure.dismissTag)
  .
  (sym_lit) @keyword.control.conditional.if.clojure (#eq? @keyword.control.conditional.if.clojure "if"))

(list_lit
  "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData clojure.dismissTag)
  .
  (sym_lit) @keyword.control.conditional.when.clojure (#eq? @keyword.control.conditional.when.clojure "when"))

(list_lit
  "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData clojure.dismissTag)
  .
  (sym_lit) @keyword.control.js.clojure (#eq? @keyword.control.js.clojure "js*"))

;; Syntax quoting
((syn_quoting_lit)
  @meta.syntax-quoted.clojure
  (#is? test.ancestorTypeNearerThan "syn_quoting_lit unquoting_lit"))

((sym_lit) @meta.symbol.syntax-quoted.clojure
  (#is? test.ancestorTypeNearerThan "syn_quoting_lit unquoting_lit")
  (#match? @meta.symbol.syntax-quoted.clojure "[^#]$"))

((sym_lit) @meta.symbol.generated.clojure
  (#is? test.ancestorTypeNearerThan "syn_quoting_lit unquoting_lit")
  (#match? @meta.symbol.generated.clojure "#$"))

;; Function calls
(list_lit
  "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData clojure.dismissTag)
  .
  (sym_lit) @keyword.control.conditional.cond.clojure (#match? @keyword.control.conditional.cond.clojure "^cond(|.|-{1,2}>)$"))

;; Other function calls
(anon_fn_lit
 "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
 .
 (sym_lit) @entity.name.function.clojure @meta.expression.clojure
 ")" @punctuation.section.expression.end.clojure)

(list_lit
 "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
 .
 (sym_lit) @entity.name.function.clojure @meta.expression.clojure
 ")" @punctuation.section.expression.end.clojure)

; NS things like require
((sym_name) @meta.symbol.clojure (#eq? @meta.symbol.clojure "import") (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")) @keyword.control.clojure
((sym_name) @meta.symbol.clojure (#eq? @meta.symbol.clojure "require") (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")) @keyword.control.clojure

;; USE
((sym_name)
 @meta.symbol.clojure
 (#eq? @meta.symbol.clojure "use")
 (#is? test.config language-clojure.markDeprecations)
 (#is-not? test.descendantOfNodeWithData clojure.dismissTag))
@invalid.deprecated.clojure

((sym_name)
 @meta.symbol.clojure
 (#eq? @meta.symbol.clojure "use")
 (#is-not? test.config language-clojure.markDeprecations)
 (#is-not? test.descendantOfNodeWithData clojure.dismissTag))
@keyword.control.clojure

;; Namespace declaration
((list_lit
  "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
  .
  (sym_lit) @meta.definition.global.clojure @keyword.control.clojure
    (#eq? @meta.definition.global.clojure "ns")
  .
  ; The namespace name carries `meta.definition.global` too, but a query cannot
  ; use one capture name twice, so it takes the longer one. A scope selector for
  ; `meta.definition.global` still matches both.
  (sym_lit) @meta.definition.global.name.clojure @entity.global.clojure
  ")" @punctuation.section.expression.end.clojure)
 @meta.namespace.clojure
 (#set! isNamespace true))

(list_lit
  "("
  .
  (kwd_lit) @invalid.deprecated.clojure (#eq? @invalid.deprecated.clojure ":use")
  (#is? test.config language-clojure.markDeprecations)
  (#is? test.descendantOfNodeWithData isNamespace))

;; Definition
(list_lit
 "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
 .
 (sym_lit) @keyword.control.clojure (#match? @keyword.control.clojure "^def(on[^\s]*|test|macro|n|n-|protocol|record|struct|)$")
 .
 (sym_lit) @meta.definition.global.clojure @entity.global.clojure
 ")" @punctuation.section.expression.end.clojure)

(list_lit
 "(" @punctuation.section.expression.begin.clojure (#is-not? test.descendantOfNodeWithData "clojure.dismissTag")
 .
 (sym_lit) @keyword.control.clojure (#match? @keyword.control.clojure "/def")
 .
 (sym_lit) @meta.definition.global.clojure @entity.global.clojure
 ")" @punctuation.section.expression.end.clojure)

;; Comment form ("Rich" comments)
((list_lit
  "(" @punctuation.section.expression.begin.clojure
  .
  (sym_lit) @meta.definition.global.clojure @keyword.control.clojure (#eq? @keyword.control.clojure "comment")
  ")" @punctuation.section.expression.end.clojure)
 @comment.block.clojure
 (#is? test.config language-clojure.commentTag)
 (#set! clojure.dismissTag true))

(list_lit
 "(" @punctuation.section.expression.begin.clojure
 .
 (sym_lit) @keyword.control.clojure (#eq? @keyword.control.clojure "comment")
 (#is-not? test.config language-clojure.commentTag)
 ")" @punctuation.section.expression.end.clojure)
