((list_lit .
  (sym_lit) @_function .
  (str_lit (str_content) @injection.content)) @injection.owner
  (#eq? @_function "js*")
  (#set! injection.language "javascript"))

((list_lit .
  (sym_lit) @_function .
  (str_lit (str_content) @injection.content)) @injection.owner
  (#eq? @_function "cpp/raw")
  (#set! injection.language "cpp"))
