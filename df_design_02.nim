import times
import typetraits
import strutils
import sequtils
import future
import macros


type
  DataFrame[T] = ref object of RootObj

  CachedDataFrame[T] = ref object of DataFrame[T]
    data: seq[T]

  MappedDataFrame[U, T] = ref object of DataFrame[T]
    orig: DataFrame[U]
    f: proc(x: U): T

  FilteredDataFrame[T] = ref object of DataFrame[T]
    orig: DataFrame[T]
    f: proc(x: T): bool

proc newCachedDataFrame[T](data: seq[T]): DataFrame[T] =
  result = CachedDataFrame[T](data: data)

# -----------------------------------------------------------------------------
# Transformations
# -----------------------------------------------------------------------------

# Issue 1: I'm getting a deprecation warning for this function:
#   `Warning: generic method not attachable to object type is deprecated`
# I don't understand why it is not attachable, T and U are both unambiguous
# from the mapping proc. Is this a showstopper, because it will break
# in a future version of Nim?
method map[U, T](df: DataFrame[U], f: proc(x: U): T): DataFrame[T] {.base.} =
  result = MappedDataFrame[U, T](orig: df, f: f)

method filter[T](df: DataFrame[T], f: proc(x: T): bool): DataFrame[T] {.base.} =
  result = FilteredDataFrame[T](orig: df, f: f)

# -----------------------------------------------------------------------------
# Iterators
# -----------------------------------------------------------------------------

# Issue 2: I don't understand why this dummy wrapper is required below.
# In the `for x in ...` lines below I was trying two variants:
#
# - `for x in it:` This gives a compilation error:
#   `Error: type mismatch: got (iterator (): int{.closure.})`
#   which is surprising because that is exactly the type required, isn't it?
# - `for x in it():` This compiles, but it leads to bugs!
#   When chaining e.g. two `map` calls the resulting iterator will
#   just return zero elements, irrespective of what the original
#   iterator is.
#
# For some strange reason converting the closure iterator to an inline
# iterator can serve as a work around.
iterator toIterBugfix[T](closureIt: iterator(): T): T {.inline.} =
  for x in closureIt():
    yield x

method iter[T](df: DataFrame[T]): (iterator(): T) {.base.} =
  quit "base method called (DataFrame.iter)"

method iter[T](df: CachedDataFrame[T]): (iterator(): T) =
  result = iterator(): T =
    for x in df.data:
      yield x

method iter[U, T](df: MappedDataFrame[U, T]): (iterator(): T) =
  result = iterator(): T =
    var it = df.orig.iter()
    for x in toIterBugfix(it): # why not just `it` or `it()`?
      yield df.f(x)

method iter[T](df: FilteredDataFrame[T]): (iterator(): T) =
  result = iterator(): T =
    var it = df.orig.iter()
    for x in toIterBugfix(it): # why not just `it` or `it()`?
      if df.f(x):
        yield x

# -----------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------

# Issue 3: I'm getting multiple warnings for this line, like:
# df_design_02.nim(87, 8) Warning: method has lock level <unknown>, but another method has 0 [LockLevel]
# df_design_02.nim(81, 8) Warning: method has lock level 0, but another method has <unknown> [LockLevel]
# df_design_02.nim(81, 8) Warning: method has lock level 0, but another method has <unknown> [LockLevel]
# df_design_02.nim(81, 8) Warning: method has lock level 0, but another method has <unknown> [LockLevel]
# df_design_02.nim(81, 8) Warning: method has lock level 0, but another method has <unknown> [LockLevel]
# Where the first warning points to the third definition of collect (the one for MappedDataFrame).
# I'm confused because none of them has a modified locklevel.
method collect[T](df: DataFrame[T]): seq[T] {.base.} =
  quit "base method called (DataFrame.collect)"

method collect[T](df: CachedDataFrame[T]): seq[T] =
  result = df.data

method collect[S, T](df: MappedDataFrame[S, T]): seq[T] =
  result = newSeq[T]()
  let it = df.orig.iter()
  for x in it():
    result.add(df.f(x))

# This issue is triggered by client clode looking like this (also
# demonstrates the iterator bug):
let data = newCachedDataFrame[int](@[1, 2, 3])
let mapped = data.map(x => x*2)
echo mapped.collect()
echo data.map(x => x*2).collect()
echo data.map(x => x*2).map(x => x*2).collect()
echo data.filter(x => x mod 2 == 1).map(x => x * 100).collect()

# Issue 4: Trying to define generic numerical actions like mean/min/max fails
# with a compilation error:
#   `Error: type mismatch: got (string) but expected 'float'`
# even though the method is never called with T being a string.
when false:
  method mean*[T](df: DataFrame[T]): float =
    result = 0
    var count = 0
    let it = df.iter()
    for x in it():
      count += 1
      result += x.float
    result /= count.float

  # The get the error it suffices (and is required) to just have a DataFrame[string]
  # in scope:
  let strData = newCachedDataFrame[string](@["A", "B"])


