type
  Base[T] = ref object of RootObj

# concrete return type: OK
method test[T](df: Base[T]): int {.base.} =
  discard

# generic return type: OK
method test[T](df: Base[T]): seq[T] {.base.} =
  discard

# iterator: Error: invalid pragma: base
method iter[T](df: Base[T]): (iterator(): T) {.base.} =
  discard