import times
import typetraits
import strutils
import sequtils
import future
import macros

type
  DataFrame[T] = ref object of RootObj

  PersistedDataFrame[T] = ref object of DataFrame[T]
    data: seq[T]

  MappedDataFrame[T, U] = ref object of DataFrame[T]
    orig: DataFrame[T]
    mapper: proc(x: T): U

proc newPersistedDataFrame[T](data: seq[T]): DataFrame[T] =
  result = PersistedDataFrame[T](data: data)

# -----------------------------------------------------------------------------
# Transformations
# -----------------------------------------------------------------------------

method map[T, U](df: DataFrame[T], f: proc(x: T): U): DataFrame[U] {.base.} =
  result = MappedDataFrame[T, U](orig: df, mapper: f)

# -----------------------------------------------------------------------------
# Iterators
# -----------------------------------------------------------------------------

iterator toIterBugfix[T](closureIt: iterator(): T): T {.inline.} =
  for x in closureIt():
    yield x

method iter[T](df: DataFrame[T]): (iterator(): T) {.base.} =
  raise newException(IOError, "unimplemented")

method iter[T](df: PersistedDataFrame[T]): (iterator(): T) =
  result = iterator(): T =
    for x in df.data:
      yield x

method iter[T, U](df: MappedDataFrame[T, U]): (iterator(): U) =
  result = iterator(): U =
    var it = df.orig.iter()
    for x in toIterBugfix(it):
      yield df.mapper(x)


# -----------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------

method collect[T](df: DataFrame[T]): seq[T] {.base.} =
  raise newException(IOError, "unimplemented")

method collect[T](df: PersistedDataFrame[T]): seq[T] =
  result = df.data

method collect[S, T](df: MappedDataFrame[S, T]): seq[T] =
  result = newSeq[T]()
  let it = df.orig.iter()
  for x in it():
    result.add(df.mapper(x))
  #for x in df.orig.

let data = newPersistedDataFrame[int](@[1, 2, 3])
echo data.collect()
echo data.map(x => x).collect()







