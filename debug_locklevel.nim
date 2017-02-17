import future

type
  DataFrame[T] = ref object of RootObj

  CachedDataFrame[T] = ref object of DataFrame[T]
    data: seq[T]

  MappedDataFrame[T, U] = ref object of DataFrame[T]
    orig: DataFrame[T]
    mapper: proc(x: T): U

# -----------------------------------------------------------------------------
# Transformations
# -----------------------------------------------------------------------------

method map[T, U](df: DataFrame[T], f: proc(x: T): U): DataFrame[U] {.base.} =
  result = MappedDataFrame[T, U](orig: df, mapper: f)

# -----------------------------------------------------------------------------
# Iterators
# -----------------------------------------------------------------------------

method iter[T](df: DataFrame[T]): (iterator(): T) {.base.} =
  raise newException(IOError, "unimplemented")

method iter[T](df: CachedDataFrame[T]): (iterator(): T) =
  discard

method iter[T, U](df: MappedDataFrame[T, U]): (iterator(): U) =
  discard

# -----------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------

method collect[T](df: DataFrame[T]): seq[T] {.base.} =
  raise newException(IOError, "unimplemented")

method collect[T](df: CachedDataFrame[T]): seq[T] =
  result = df.data

method collect[S, T](df: MappedDataFrame[S, T]): seq[T] =
  result = newSeq[T]()
  let it = df.orig.iter()
  for x in it():
    result.add(df.mapper(x))

let data = CachedDataFrame[int](data: @[1, 2, 3])
echo data.map(x => x).collect()







