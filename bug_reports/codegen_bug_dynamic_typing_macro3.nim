import macros

#[
result = newStmtList(result)
result.add(newLetStmt(varname, newIntLitNode(1)))
result.add(procBody)
]#

#[
macro injectSymbolInIfBranches(varname: untyped, procBody: untyped): untyped =
  result = newIfStmt()
  for i in [1, 2]:
    let elifBranch = newNimNode(nnkElifBranch)
    let cond = bindSym"true"
    let body = newStmtList()
    body.add(newLetStmt(varname, newIntLitNode(1)))
    body.add(procBody)
    elifBranch.add(cond)
    elifBranch.add(body)
    result.add(elifBranch)
  echo result.repr
]#

macro injectSymbolInBlocks(varname: untyped, procBody: untyped): untyped =
  result = newStmtList()
  for i in [1, 2]: # only fails with more than 1 block
    let body = newStmtList()
    body.add(newLetStmt(varname, newIntLitNode(1)))
    body.add(procBody)
    result.add(newBlockStmt(body))
  echo result.repr

# This causes the codegen to fail
proc macroVersion() =
  injectSymbolInBlocks(a):
    echo a

# This works fine, although it should have the same AST
proc manualVersion() =
  block:
    let a = 1
    echo a
  block:
    let a = 1
    echo a
