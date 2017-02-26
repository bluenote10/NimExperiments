type
  Iterator*[T] = ref object of RootObj

# base methods without `T` (void or basic types) fail
method someMethod*[T](i: Iterator[T]) {.base.} =
  discard

type
  SpecificIterator1* = ref object of Iterator[string]
  SpecificIterator2* = ref object of Iterator[int]

