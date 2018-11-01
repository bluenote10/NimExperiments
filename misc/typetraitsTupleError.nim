
import typetraits

proc takesTuple(t: tuple) =
  echo t
  #echo t.type.name
  #echo t.type.arity
  echo repr(t.type)

var
  t = (1, "Test", (1,2,3), 3.14)

takesTuple(t)
