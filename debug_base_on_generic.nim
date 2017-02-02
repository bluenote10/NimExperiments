

type
  Iterator[T] = ref object of RootObj

  CachedIterator[T] = ref object of Iterator[T]
  FileRowIterator = ref object of Iterator[string]

method someMethod[T](g: Iterator[T]) {.base.} =
  discard

method someMethod[T](g: CachedIterator[T]) =
  discard

method someMethod(g: FileRowIterator) =
  discard
