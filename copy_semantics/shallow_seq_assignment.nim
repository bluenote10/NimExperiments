
type
  DataUntyped* = ref object of RootObj
    some: int

  #Data* {.shallow.} [T]  = ref object of DataUntyped # doesn't have any effect?

  Data* [T]  = ref object of DataUntyped
    data*: seq[T]


proc copyShallow[T](d: Data[T]): Data[T] =
  #[
  # looks like it is not possible to get a shallow assignment
  # in the standard object constructor...
  var dLocal = d
  var dLocalData: seq[T]
  echo dLocal.repr
  echo dLocalData.repr
  shallowCopy(dLocalData, d.data)
  echo dLocalData.repr
  Data[T](
    some: d.some + 1,
    #data: d.data,
    data: dLocalData,
  )
  ]#
  result = Data[T](
    some: d.some + 1,
  )
  shallowCopy(result.data, d.data)


let d1 = Data[int](data: @[1, 2, 3])
let d2 = d1.copyShallow()

echo d1[]
echo d1.repr
echo d2[]
echo d2.repr