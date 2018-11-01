when false:
  import future

  when defined(nimlocks):
    {.pragma: benign, gcsafe, locks: 0.}
  else:
    {.pragma: benign, gcsafe.}

  type
    DataFrame[T] = ref object of RootObj

    CachedDataFrame[T] = ref object of DataFrame[T]
      data: seq[T]

    MappedDataFrame[T, U] = ref object of DataFrame[T]
      orig: DataFrame[T]
      mapper: proc(x: T): U {.locks: 0.}

  # -----------------------------------------------------------------------------
  # Iterators
  # -----------------------------------------------------------------------------

  method iter[T](df: DataFrame[T]): (iterator(): T) {.base, locks: 0.} =
    raise newException(IOError, "unimplemented")

  method iter[T](df: CachedDataFrame[T]): (iterator(): T) {.locks: 0.} =
    discard

  method iter[T, U](df: MappedDataFrame[T, U]): (iterator(): U) {.locks: 0.} =
    discard

  # -----------------------------------------------------------------------------
  # Actions
  # -----------------------------------------------------------------------------

  method collect[T](df: DataFrame[T]): seq[T] {.base, locks: nil.} =
    raise newException(IOError, "unimplemented")

  method collect[T](df: CachedDataFrame[T]): seq[T] {.locks: nil.} =
    result = df.data

  method collect[S, T](df: MappedDataFrame[S, T]): seq[T] {.locks: nil.} =
    result = newSeq[T]()
    let it = df.orig.iter()
    for x in it():
      result.add(df.mapper(x))

  # -----------------------------------------------------------------------------
  # Transformations
  # -----------------------------------------------------------------------------

  proc map[T, U](df: DataFrame[T], f: proc(x: T): U): DataFrame[U] =
    result = MappedDataFrame[T, U](orig: df, mapper: f)

  let data = CachedDataFrame[int](data: @[1, 2, 3])
  echo data.map(x => x).collect()

else:
  type SomeBase* = ref object of RootObj
  type SomeDerived* = ref object of SomeBase
    memberProc*: proc () # preferred solution: {.locks: 0.}

  method testMethod(g: SomeBase) {.base, locks: nil.} = discard
  method testMethod(g: SomeDerived) =
    if g.memberProc != nil:
      g.memberProc()

