; A rich `(comment ...)` form owns its entire range. Store that fact before
; resolving its children so ordinary call scopes can opt out below.
((list_lit) @comment.block.clojure
  (#is? test.matchAt "firstNamedChild ^comment$")
  (#is? test.config language-clojure.commentTag)
  (#set! clojure.dismissTag true))

; List punctuation stays leaf-rooted: a list can contain arbitrarily many
; forms, while the relationship checks below are constant-time.
("(" @punctuation.section.expression.begin.clojure
  (#is? test.childOfType list_lit)
  (#is? test.first true)
  (#is? test.typeAt "parent.firstNamedChild sym_lit")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

(")" @punctuation.section.expression.end.clojure
  (#is? test.childOfType list_lit)
  (#is? test.last true)
  (#is? test.typeAt "parent.firstNamedChild sym_lit")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

; Anonymous function literals have a leading `#` before their opening paren.
("(" @punctuation.section.expression.begin.clojure
  (#is? test.childOfType anon_fn_lit)
  (#is? test.typeAt "previousSibling #")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

(")" @punctuation.section.expression.end.clojure
  (#is? test.childOfType anon_fn_lit)
  (#is? test.last true)
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

; The comment form still exposes its delimiters and head inside the comment
; scope; ordinary list punctuation above is deliberately suppressed there.
("(" @punctuation.section.expression.begin.clojure
  (#is? test.childOfType list_lit)
  (#is? test.first true)
  (#is? test.matchAt "parent.firstNamedChild ^comment$")
  (#is? test.config language-clojure.commentTag))

(")" @punctuation.section.expression.end.clojure
  (#is? test.childOfType list_lit)
  (#is? test.last true)
  (#is? test.matchAt "parent.firstNamedChild ^comment$")
  (#is? test.config language-clojure.commentTag))

; Special forms. Each captured symbol is the first named child of a list; its
; previous sibling is therefore the anonymous opening parenthesis.
((sym_lit) @storage.control.clojure
  (#eq? @storage.control.clojure "do")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

((sym_lit) @keyword.control.conditional.if.clojure
  (#eq? @keyword.control.conditional.if.clojure "if")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

((sym_lit) @keyword.control.conditional.when.clojure
  (#eq? @keyword.control.conditional.when.clojure "when")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

((sym_lit) @keyword.control.js.clojure
  (#eq? @keyword.control.js.clojure "js*")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

((sym_lit) @keyword.control.conditional.cond.clojure
  (#match? @keyword.control.conditional.cond.clojure "^cond(|.|-{1,2}>)$")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

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

; Ordinary function-call heads.
((sym_lit) @entity.name.function.clojure @meta.expression.clojure
  (#is? test.childOfType "list_lit anon_fn_lit")
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

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
((list_lit) @meta.namespace.clojure
  (#is? test.matchAt "firstNamedChild ^ns$")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag)
  (#set! isNamespace true))

((sym_lit) @meta.definition.global.clojure @keyword.control.clojure
  (#eq? @meta.definition.global.clojure "ns")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

; The namespace name carries `meta.definition.global` too, but a query cannot
; use one capture name twice, so it takes the longer one. A scope selector for
; `meta.definition.global` still matches both.
((sym_lit) @meta.definition.global.name.clojure @entity.global.clojure
  (#is? test.childOfType list_lit)
  (#is? test.matchAt "previousNamedSibling ^ns$")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

((kwd_lit) @invalid.deprecated.clojure
  (#eq? @invalid.deprecated.clojure ":use")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is? test.config language-clojure.markDeprecations)
  (#is? test.descendantOfNodeWithData isNamespace))

;; Definitions
((sym_lit) @keyword.control.clojure
  (#match? @keyword.control.clojure "^def(on[^\s]*|test|macro|n|n-|protocol|record|struct|)$")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

((sym_lit) @meta.definition.global.clojure @entity.global.clojure
  (#is? test.childOfType list_lit)
  (#is? test.matchAt "previousNamedSibling ^def(on[^\s]*|test|macro|n|n-|protocol|record|struct|)$")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

((sym_lit) @keyword.control.clojure
  (#match? @keyword.control.clojure "/def")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

((sym_lit) @meta.definition.global.clojure @entity.global.clojure
  (#is? test.childOfType list_lit)
  (#is? test.matchAt "previousNamedSibling /def")
  (#is-not? test.descendantOfNodeWithData clojure.dismissTag))

;; Comment form head
((sym_lit) @meta.definition.global.clojure @keyword.control.clojure
  (#eq? @keyword.control.clojure "comment")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is? test.config language-clojure.commentTag))

((sym_lit) @keyword.control.clojure
  (#eq? @keyword.control.clojure "comment")
  (#is? test.childOfType list_lit)
  (#is? test.typeAt "previousSibling (")
  (#is-not? test.config language-clojure.commentTag))
