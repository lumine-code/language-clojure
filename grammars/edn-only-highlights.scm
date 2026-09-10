(list_lit) @meta.list.clojure

("(" @punctuation.section.list.begin.clojure
  (#is? test.childOfType list_lit)
  (#is-not? test.descendantOfNodeWithData "clojure.dismissTag"))

(")" @punctuation.section.list.end.clojure
  (#is? test.childOfType list_lit))
