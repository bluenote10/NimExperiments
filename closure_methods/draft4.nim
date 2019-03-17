#[
type
  Generic[T] = ref object
    getState*: proc(): T

proc newGeneric[T](): Generic[T] =
  var state: T

  proc getState[T](): T =
    state

  Generic[T](
    getState: getState
  )

let g = newGeneric[int]()
let state = g.getState()
echo(state)
]#

import closure_methods

when true:
  class(Base[T]):

    constructor:
      proc newBase[T](xInit: T = 10)

    vars:
      var x: T

    procs:
      discard
      #proc add(add: T) =
      #  x += add

      #proc getState(): T =
      #  x

  let x = newBase[int](20)
  #echo x.getState()
  #x.add(100)
  #echo x.getState()


when false:
  type
    Base[T] = ref object of RootObj
      add: proc (add: T)
      getState: proc (): T

  proc newBase[T](xInit: T = 10): Base[T] =
    var x: T
    proc add(add: T) =
      x += add

    proc getState(): T =
      x

    Base[T](add: add, getState: getState)

  let x = newBase[int](20)
  echo x.getState()
  x.add(100)
  echo x.getState()


when false:
  import macros
  dumpTree:
    type
      Base[T] = ref object of RootObj
        add: proc (add: T)
        getState: proc (): T

    proc newBase[T](xInit: T = 10): Base[T] =
      var x: T
      proc add(add: T) =
        x += add

      proc getState(): T =
        x

      Base[T](add: add, getState: getState)
