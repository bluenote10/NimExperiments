import macros

type
  Base[T] = ref object

dumpTree: # reference tree to be produced by macro below
  proc clone[T](self: Base[T]): Base[T] =
    discard

macro genCloneProc(typeWithGenArg: untyped): untyped =
  echo typeWithGenArg.treeRepr
  # =>
  #   BracketExpr
  #     Ident "Base"
  #     Ident "T"
  result = newProc(
    ident "clone", [
      typeWithGenArg, # return type: Base[T]
      newIdentDefs(
        ident "self",
        typeWithGenArg,
      )
    ],
    newStmtList(
      newNimNode(nnkDiscardStmt).add(newEmptyNode())
    )
  )
  # set the generic param 
  let genericParamIdent = typeWithGenArg[1] # the `T`
  result[2] = newNimNode(nnkGenericParams)
  result[2].add(newIdentDefs(genericParamIdent, newEmptyNode()))
  echo result.repr
  echo result.treeRepr

genCloneProc(Base[T])
