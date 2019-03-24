import closure_methods

class(Base, RootObj):
  #constructor(newBase) = 
  #  proc(xInit: int = 10)

  constructor:
    proc newBase*(xInit: int = 10)

  var x = xInit

  proc inc() =
    x += 1

  proc getState*(): int =
    inc()
    x

block:
  let b = newBase()
  echo b.getState()
  echo b.getState()

when false:
  class(Sub, Base):
    constructor:
      proc newSub*(xInit: int)

    base:
      newBase(xInit)

    vars:
      var xState = "state"

    procs:
      proc subProc*(): string =
        xState

  block:
    let s = newSub(20)
    echo s.getState()
    echo s.getState()
    echo s.subProc()


when false:
  class(SubSub, Sub):
    constructor:
      proc newSubSub*()

    base:
      newSub(30)

    vars:
      var x = "subsub"

    procs:
      proc subSubProc*(): string =
        x

  block:
    let s = newSubSub()
    echo s.getState()
    echo s.getState()
    echo s.subProc()
    echo s.subSubProc()