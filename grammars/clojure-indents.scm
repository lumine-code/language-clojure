; An unfinished string inside an open form keeps its literal row margin.
(ERROR "\"" @match.next
  (#set! indent.match startPosition))

; Reindent changes code structure, never the contents of multiline literals
; or the alignment a user chose inside a block comment.
([(str_lit) (regex_lit) (comment)] @preserve
  (#is? indent.reindent true)
  (#is-not? indent.matchesCurrentRow startPosition)
  (#set! indent.force true))

; Only explicit delimiters change the inherited indentation. Layout,
; operators and unfinished expressions deliberately keep the current level.
["(" "[" "{"] @indent
[")" "]" "}"] @dedent
