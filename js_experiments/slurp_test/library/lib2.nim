#[
template bundleModules*(modules: static[openarray[string]]) =
  static:
    for module in modules:
      const m = module
      #{.emit: module.}
]#

#[
template bundleModules*(modules: static[varargs[string]]) =
  for module in modules:
    const m = module
]#

import macros


template testImpl(slurpCall) {.dirty.} =
  #static:
  const moduleCode = slurpCall # slurp("jsmoduleA.js")
  echo moduleCode


macro bundleModules*(modules: typed): untyped =

  expectKind modules, nnkBracket

  result = newStmtList()
  for module in modules:
    expectKind module, nnkStrLit
    var slurpCall = newCall(ident "slurp", newStrLitNode module.strVal)
    slurpCall.copyLineInfo(modules)

    #let echoCall = newCall(ident "echo", slurpCall)
    #result = newNimNode(nnkStaticStmt).add(echoCall)
    #result = getAst(testImpl(slurpCall))

    result.add(
      newNimNode(nnkPragma).add(
        newColonExpr(ident "emit", slurpCall)
      )
    )

  echo result.repr
