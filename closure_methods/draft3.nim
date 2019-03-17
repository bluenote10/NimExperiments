import closure_methods

class(Base):
  type
    Base = ref object of RootObj
      getState: proc(x: int): int

  constructor:
    proc newBase(xInit: int = 10)

  vars:
    var x = 0

  procs:
    proc inc() =
      x += 1

    proc getState*(): int =
      inc()
      x