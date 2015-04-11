

#proc f(t: typedecl)

#template iterate(T: typedesc[int]): float = Inf

#template iterate(T: typedesc[int]): expr =

template iterate(): expr =
  var i = 0
  iterator iter(): int {.closure, gensym.} =
    yield i
    inc i
  #items(iter)
  #iter.items
  #iter()
  iter

for x in iterate():
  echo x
  if x > 10:
    break




