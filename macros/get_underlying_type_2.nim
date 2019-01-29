import typetraits
import macros

type
  Object[T] = object

proc test[X](x: X) =
  # It looks like accessing the underlying generic type
  # only works for user objects. Unfortunately seq and
  # array don't support this, or it is undocumented what
  # is the type symbol.
  when X is Object:
    echo "Object"
  when X is Object:
    when x.T is int:
      echo "Object[int]"
  when X is seq:
    echo X.T
  when X is array:
    echo X.T

test(Object[int]())
test([1])
test([""])