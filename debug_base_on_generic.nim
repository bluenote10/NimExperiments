type
  Iterator[T] = ref object of RootObj

  CachedIterator[T] = ref object of Iterator[T]
    s: seq[T]
  FileRowIterator[T] = ref object of Iterator[T]

method collect*[T](i: Iterator[T]): seq[T] {.base.} =
  quit "to override"

method collect*[T](i: CachedIterator[T]): seq[T] =
  result = i.s

method collect*(i: FileRowIterator[string]): seq[string] =
  result = @["1i", "2i", "3i"]



method iter*[T](df: Iterator[T]): (iterator(): T) =
  discard

method iter*[T](df: CachedIterator[T]): (iterator(): T) =
  result = iterator(): T =
    for x in df.s:
      yield x

method iter*(df: FileRowIterator[string]): (iterator(): string) =
  result = iterator(): string =
    yield "1"
    yield "2"
    yield "3"


proc newCachedIterator[T](s: seq[T]): Iterator[T] =
  result = CachedIterator[T](s: s)

proc newFileRowIterator(): Iterator[string] =
  result = FileRowIterator[string]()

proc somethingGeneric[T](iter: Iterator[T]) =
  echo iter.collect()

let it1 = newCachedIterator(@[1, 2, 3])
echo it1.collect()
somethingGeneric(it1)

let it2 = newCachedIterator(@["A", "B", "C"])
echo it2.collect()
somethingGeneric(it2)

let it3 = newFileRowIterator()
echo it3.collect()
somethingGeneric(it3)