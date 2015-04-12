

#proc f(t: typedecl)

#template iterate(T: typedesc[int]): float = Inf

#template iterate(T: typedesc[int]): expr =

when false:
  template iterate(): expr =
    var i = 0
    iterator iter(): int {.closure, gensym.} =
      yield i
      inc i
    #items(iter)
    #iter.items
    #iter()
    iter

  for x in iterate():
    echo x
    if x > 10:
      break


when false:

  iterator infinite(): int {.closure.} = # not using closures causes type mismatch
    var i = 0
    while true:
      yield i
      inc i

  iterator even(it: iterator (): int): int {.closure.} =
    for x in it(): # omitting parentheses causes Error: type mismatch: got (iterator (): int{.closure.}),
                   # but expected one of: <... variants of system.items ...>
      if x mod 2 == 0:
        yield x

  iterator take[T](it: iterator (): T, numToTake: int): T {.closure.} =
    var i = 0
    for x in it():
      if i < numToTake:
        yield x
      inc i

  #echo "here"
  for x in infinite.take(10):
  #for x in infinite():
    echo x

  echo "done"
  
  discard """
  #for x in infinite():       # works
  #for x in even(infinite()): # undeclared identifier: 'infinite'
  #for x in even(infinite):   # compiles but never increments
  for x in infinite.even:     # compiles but never increments
    echo x
    if x == 10: break
  """
  
  discard """
iterate.nim(33, 13) Error: internal error: expr: param not init it_90238
Traceback (most recent call last)
nim.nim(94)              nim
nim.nim(56)              handleCmdLine
main.nim(252)            mainCommand
main.nim(63)             commandCompileToC
modules.nim(203)         compileProject
modules.nim(151)         compileModule
passes.nim(197)          processModule
passes.nim(137)          processTopLevelStmt
cgen.nim(1210)           myProcess
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2057)       expr
ccgstmts.nim(480)        genBlock
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2057)       expr
ccgstmts.nim(480)        genBlock
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2078)       expr
ccgstmts.nim(462)        genWhileStmt
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2060)       expr
ccgstmts.nim(1079)       genStmts
ccgexprs.nim(2079)       expr
ccgstmts.nim(250)        genVarStmt
ccgstmts.nim(233)        genSingleVar
ccgstmts.nim(75)         loadInto
ccgcalls.nim(539)        genAsgnCall
ccgcalls.nim(193)        genClosureCall
cgen.nim(478)            initLocExpr
ccgexprs.nim(2004)       expr
msgs.nim(836)            internalError
msgs.nim(813)            liMessage
msgs.nim(715)            handleError
FAILURE
 
  """


when true:

  iterator infinite(): int {.closure.} = # not using closures causes type mismatch
    var i = 0
    while true:
      yield i
      inc i

  template oddIndices1[T](iter: iterator(): T): auto {.immediate.} =
    (iterator (): type(iter()) =
      for item in iter:
        yield item)

  template take[T](it: iterator(): T, numToTake: int): expr =
    var i = 0
    iterator tmp(): type(it()) =
      for item in it:
        if i < numToTake:
          yield item
          inc i
    tmp

  for x in infinite.take(10)():
    echo x
    
  discard """
  template oddIndices[T](iter: iterator (): T): (iterator (): T) {.immediate.} =
    iterator tmp(): T =
      var i = 0
      for item in iter:
        if i mod 2 == 0:
          yield item
        inc i
  
  for x in oddIndices1(infinite):
    echo x
    if x == 10: break
  """
  
