; EDN maps have flat repeated value fields instead of key/value pair nodes.
; Only even field positions are keys; keyword values and discarded forms are
; not declarations. Capture the whole key so the field predicate sees it.
([(kwd_lit) (str_lit) (sym_lit)] @name
  (#is? test.childOfType "map_lit ns_map_lit")
  (#is? test.fieldIndex "value even")
  (#set! symbol.strip "^:|^\"|\"$")
  (#set! symbol.tag "property"))
