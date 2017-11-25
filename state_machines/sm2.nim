
type
  Waiting = object
    waitingTime: float

  Filling = object
    rate: float

  Done = object

  StateMachine[S] = object
    state: S


proc initStateMachine(): StateMachine[Waiting] =
  StateMachine[Waiting](state: Waiting(waitingTime: 0))

proc toFilling(sm: StateMachine[Waiting]): StateMachine[Filling] =
  StateMachine[Filling](state: Filling(rate: 1))

proc toDone(sm: StateMachine[Filling]): StateMachine[Done] =
  StateMachine[Done](state: Done())

proc toWaiting(sm: StateMachine[Done]): StateMachine[Waiting] =
  StateMachine[Waiting](state: Waiting(waitingTime: 0))


let sm1 = initStateMachine()
let sm2 = sm1.toFilling()
let sm2b = sm1.toFilling() # this should be illegal
let sm3 = sm2.toDone()
let sm4 = sm3.toWaiting()
doAssert(not compiles(sm4.toDone())) # bad transition
