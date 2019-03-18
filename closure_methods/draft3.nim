import closure_methods

class(Base):
  constructor:
    proc newBase*(xInit: int = 10)

  vars:
    var x = xInit

  procs:
    proc inc() =
      x += 1

    proc getState*(): int =
      inc()
      x


let b = newBase()
echo b.getState()
echo b.getState()


class(Sub of Base):
  constructor:
    proc newSub*(xInit: int)

  base:
    newBase(xInit)

  vars:
    var x = "state"

  procs:
    proc subProc*(): string =
      x

let s = newSub(20)
echo s.getState()
echo s.getState()
echo s.subProc()