
type
  TypedData[T] = ref object
    data: seq[T]

  UntypedData = ref object

  Col = object
    data: UntypedData

block:
  echo "block 1"
  let t = TypedData[int](data: @[1, 2, 3])
  let u = cast[UntypedData](t)
  let c = Col(data: u)
  echo t.repr
  echo u.repr
  echo c.repr

proc test(): Col =
  let t = TypedData[int](data: @[1, 2, 3])
  let u = cast[UntypedData](t)
  let c = Col(data: u)
  echo t.repr
  echo u.repr
  echo c.repr

block:
  echo "block 2"
  let c = test()
  echo c.repr
  GC_fullCollect()
  echo c.repr
  doAssert c.data != nil  # data becomes nil, apparently casted references don't count

