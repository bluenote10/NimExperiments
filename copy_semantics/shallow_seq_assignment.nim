import strutils
import strformat

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


proc convertToId[T](p: ptr T): string =
  #[
  echo p.repr
  if p[].isNil:
    "nil"
  else:
  ]#
  (&"0x{cast[int](p[]):X}").toLowerAscii


proc getDataId[T](d: Data[T]): string =
  #let p = unsafeAddr(d.data)
  #let id = "0x" & cast[int](p[]).toHex.toLowerAscii
  #let id = (&"0x{cast[int](p[]):X}").toLowerAscii
  #let id = "0x" & cast[int](d.data).toHex.toLowerAscii
  #echo "d.repr: ", d.repr
  #echo "p.repr: ", p.repr
  #convertToId(p)
  if d.data.len == 0:
    "empty"
  else:
    let p = unsafeAddr(d.data)
    convertToId(p)


proc getId[T](d: Data[T]): string =
  #let id = "0x" & cast[int](p[]).toHex.toLowerAscii
  #let id = (&"0x{cast[int](p[]):X}").toLowerAscii
  #let id = "0x" & cast[int](d.data).toHex.toLowerAscii
  #echo "d.repr: ", d.repr
  #echo "p.repr: ", p.repr
  if d.isNil:
    "nil"
  else:
    let p = unsafeAddr(d)
    convertToId(p)


let d1 = Data[int](data: @[1, 2, 3])
let d2 = d1.copyShallow()

echo d1[]
echo d1.getId
echo d1.getDataId
echo d1.repr

echo d2[]
echo d2.getId
echo d2.getDataId
echo d2.repr

var d3: Data[int]
echo d3.getId

var d4 = Data[int](data: @[])
echo d4.getDataId