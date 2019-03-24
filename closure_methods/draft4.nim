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

class(Base[T], RootObj):
  constructor:
    proc newBase[T](xInit: T = 10): Base[T]

  var x: T

  proc add*(add: T) =
    x += add

  proc getState*(): T =
    x

let x = newBase[int](20)
echo x.getState()
x.add(100)
echo x.getState()

