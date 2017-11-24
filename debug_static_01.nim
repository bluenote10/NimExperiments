when false:
  type
    Base = ref object of RootObj
    Test[T: static[seq[string]]] = ref object of Base

  method test(t: Base) {.base.} =
    echo "base"

  method test[T](t: Test[T]) =
    echo "test"

  const s = @["a", "b"]
  let t = Test[s]()
  t.test()

when false:
  type
    Base = ref object of RootObj
    Test[T: static[int]] = ref object of Base

  method test(t: Base) {.base.} =
    echo "base"

  method test[T](t: Test[T]) =
    echo "test"

  let t = Test[1]()

when false:    
  type
    Base[T: static[int]] = ref object of RootObj

  method test[T](t: Base[T]) {.base.} =
    discard

  let x = Base[1]()

when false:
  type
    Base[T: static[int]] = ref object of RootObj

  proc test[T](t: Base[T]) =
    echo t.T

  let x1 = Base[1]()
  let x2 = Base[2]()
  let x3 = Base[3]()

  x1.test()
  x2.test()
  x3.test()

when true:
  type
    Base[T] = ref object of RootObj
    Test[T; N: static[int]] = ref object of Base[T]