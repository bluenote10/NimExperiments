proc debug*[T](x: T) {.importc: "console.log", varargs.}

type
  Base = ref object of RootObj
    getState*: proc(): int
    x*: int
    privateState: int

  Sub = ref object of Base
    privateState2: cstring
    subMethod*: (proc(x: int): int)


proc newBase(): Base =
  let base = RootObj()
  let self = Base()
  self.x = 0              # taken from public field block
  self.privateState = 0   # taken from private field block

  # same goes for private methods
  proc inc(x: int): int = x + 1

  # definitions of public methods
  proc getState(): int =
    self.privateState = inc(self.privateState)
    self.x = inc(self.privateState)
    self.privateState

  self.getState = getState
  self

proc newSub(): Sub =
  let base = newBase()
  let self = Sub()
  self.privateState2 = cstring"state"

  proc subMethod(x: int): int =
    x + 1

  self.getState = base.getState
  self.subMethod = subMethod
  self

let b = newBase()
debug(b.getState())
debug(b.x)
debug(b.getState())
debug(b.x)

let s = newSub()
debug(s.getState())
