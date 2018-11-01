import macros

macro addFields*(t: typed, fields: varargs[untyped]): untyped =
  echo fields.len
  echo fields.repr
  echo fields.treeRepr
  # actual implementation omitted
  result = quote do: `t`

let t = (x: 1.0, y: 1.0)

# not using colon expressions work:
echo t.addFields(works, withPlain, expressions)

# not using method call syntax works
echo addFields(t, length: sqrt(t.x^2 + t.y^2))

# fails in combination
echo t.addFields(length: sqrt(t.x^2 + t.y^2))

#[
Traceback working version:
nim.nim(121)             nim
nim.nim(77)              handleCmdLine
main.nim(163)            mainCommand
main.nim(74)             commandCompileToC
modules.nim(240)         compileProject
modules.nim(180)         compileModule
passes.nim(215)          processModule
passes.nim(135)          processTopLevelStmt
sem.nim(512)             myProcess
sem.nim(484)             semStmtAndGenerateGenerics
semstmts.nim(1646)       semStmt
semexprs.nim(819)        semExprNoType
semexprs.nim(2364)       semExpr
semstmts.nim(1474)       semMacroDef
semstmts.nim(1371)       semProcAux
semexprs.nim(1430)       semProcBody
semexprs.nim(2343)       semExpr
semstmts.nim(1600)       semStmtList
semexprs.nim(2265)       semExpr
semexprs.nim(1836)       semMagic
semexprs.nim(802)        semDirectOp
semexprs.nim(640)        semOverloadedCallAnalyseEffects
semcall.nim(388)         semOverloadedCall

Traceback failing version:
nim.nim(121)             nim
nim.nim(77)              handleCmdLine
main.nim(163)            mainCommand
main.nim(74)             commandCompileToC
modules.nim(240)         compileProject
modules.nim(180)         compileModule
passes.nim(215)          processModule
passes.nim(135)          processTopLevelStmt
sem.nim(512)             myProcess
sem.nim(484)             semStmtAndGenerateGenerics
semstmts.nim(1646)       semStmt
semexprs.nim(819)        semExprNoType
semexprs.nim(2364)       semExpr
semstmts.nim(1474)       semMacroDef
semstmts.nim(1371)       semProcAux
semexprs.nim(1430)       semProcBody
semexprs.nim(2343)       semExpr
semstmts.nim(1600)       semStmtList
semexprs.nim(2265)       semExpr
semexprs.nim(1836)       semMagic                              <= node still complete, but shows that it is parsed as nkObjConstr instead of nkCall
semexprs.nim(802)        semDirectOp
semexprs.nim(640)        semOverloadedCallAnalyseEffects
semcall.nim(388)         semOverloadedCall                     <= node truncated to `call => addFields => t`


if ($n.info).contains("debug_untyped_varargs.nim"):
  echo "HERE"
  debug(n)
  let s: string = nil
  echo s[0]

]#