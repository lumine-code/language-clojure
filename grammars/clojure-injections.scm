((list_lit .
  (sym_lit) @_function .
  (str_lit (str_content) @injection.content)) @injection.owner
  (#eq? @_function "js*")
  (#set! injection.language "javascript")
  (#set! injection.content-edit-policy "content-words"))

((list_lit .
  (sym_lit) @_function .
  (str_lit (str_content) @injection.content)) @injection.owner
  (#eq? @_function "cpp/raw")
  (#set! injection.language "cpp")
  (#set! injection.content-edit-policy "content-words"))
