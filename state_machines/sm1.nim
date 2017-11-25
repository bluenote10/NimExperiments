
type
  StateKind = enum
    Waiting, Filling, Done

  State = object
    case kind: StateKind
    of Waiting:
      waitingTime: float
    of Filling:
      rate: float
    of Done:
      discard

  StateMachine = object
    state: State


proc initStateMachine(): StateMachine =
  StateMachine(state: State(kind: Waiting, waitingTime: 0))

proc toFilling(sm: var StateMachine) =
  case sm.state.kind
  of Waiting:
    sm.state = State(kind: Filling, rate: 1)
  else:
    raise newException(ValueError, "bad transition")

proc toDone(sm: var StateMachine) =
  case sm.state.kind
  of Filling:
    sm.state = State(kind: Done)
  else:
    raise newException(ValueError, "bad transition")

proc toWaiting(sm: var StateMachine) =
  case sm.state.kind
  of Done:
    sm.state = State(kind: Waiting, waitingTime: 0)
  else:
    raise newException(ValueError, "bad transition")

var sm = initStateMachine()
sm.toFilling()
sm.toDone()
sm.toWaiting()
sm.toDone() # bad transition
