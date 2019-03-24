import macros

#[
type
  Base[T] = ref object of RootObj
    add*: proc (add: T)
    getState*: proc (): T

proc patch[T](self: Base[T]): proc (xInit: T = 10) =
  result = proc (xInit: T = 10) =
    var x: T
    self.add = proc (add: T) =
      x += add
    self.getState = proc (): T =
      x

proc newBase[T](xInit: T = 10): Base[T] =
  let self = Base[T]()
  patch(self)(xInit)
  self
]#


type
  Base[T] = ref object

dumpTree:
  proc init[T](self: Base[T]) =
    discard

macro gen(t: untyped): untyped =
  echo t.treeRepr
  let genericParam = t[1] 
  result = newProc(
    ident "init",
    [
      newEmptyNode(), # void return type
      newIdentDefs(
        ident "self",
        t,
      )
    ],
    newStmtList()
  )
  result[2] = newNimNode(nnkGenericParams)
  result[2].add(newIdentDefs(genericParam, newEmptyNode()))
  echo result.repr
  echo result.treeRepr

gen(Base[T])
