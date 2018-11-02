import strformat

type
  Object = ref object of RootObj
    id: int

  Sub[T] = ref object of Object
    data: seq[T]

method test(o: Object): string {.base.} =
  ""

method test[T](o: Sub[T]): string =
  #&"{cast[int](o.id):X}"
  let p = unsafeAddr(o.data)
  #convertToId(p)
  let i = cast[int](p[])
  let s = &"{i:X}"
  s

proc generic[T](o: Sub[T]): Sub[float] =
  echo o.test()

let o = Sub[string]()
let x = o.generic()
