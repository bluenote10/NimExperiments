when false:
  type
    Iterator[T] = ref object of RootObj

    CachedIterator[T] = ref object of Iterator[T]
      s: seq[T]
    FileRowIterator = ref object of Iterator[string]

  method collect*[T](i: Iterator[T]): seq[T] {.base.} =
    quit "to override"

  method collect*[T](i: CachedIterator[T]): seq[T] =
    result = i.s

  method collect*(i: FileRowIterator): seq[string] =
    result = @["1", "2", "3"]

  proc newFileRowIterator(): Iterator[string] =
    result = FileRowIterator()

  let it = newFileRowIterator()
  discard it.collect()

when true:
  # First: generic types _only_ (specialized types must wait)
  type
    Iterator[T] = ref object of RootObj

    CachedIterator[T] = ref object of Iterator[T]
      s: seq[T]

  # ... with generic methods
  method collect*[T](i: Iterator[T]): seq[T] {.base.} =
    quit "to override"

  method collect*[T](i: CachedIterator[T]): seq[T] =
    result = i.s

  # And only now: specialized types and their methods
  type
    FileRowIterator = ref object of Iterator[string]
    RangeIterator = ref object of Iterator[int]

  method collect*(i: FileRowIterator): seq[string] =
    result = @["1", "2", "3"]
  method collect*(i: RangeIterator): seq[int] =
    result = @[1, 2, 3]

  proc newCachedIterator[T](s: seq[T]): Iterator[T] =
    result = CachedIterator[T](s: s)
  proc newFileRowIterator(): Iterator[string] =
    result = FileRowIterator()
  proc newRangeIterator(): Iterator[int] =
    result = RangeIterator()

  let it1 = newCachedIterator[int](@[1, 2, 3])
  echo it1.collect()
  let it2 = newFileRowIterator()
  echo it2.collect()
  let it3 = newRangeIterator()
  echo it3.collect()
