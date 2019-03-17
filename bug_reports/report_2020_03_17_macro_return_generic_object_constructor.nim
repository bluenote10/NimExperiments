import macros

type
  Generic[T] = ref object
    x: T

dumpTree:
  proc test1[T](): Generic[T] =
    Generic[T](x: T(0))

when true:
  proc test1[T](): Generic[T] =
    Generic[T](x: T(0))

#macro genTest() =

macro macroProc(): untyped =
  let p = newProc(ident "test2", params=[
    newNimNode(nnkBracketExpr).add(
      ident "Generic",
      ident "T")
    ])
  let objectConstructor = newNimNode(nnkObjConstr).add(
    newNimNode(nnkBracketExpr).add(
      ident "Generic",
      ident "T",
    ),
    newNimNode(nnkExprColonExpr).add(
      ident "x",
      newNimNode(nnkCall).add(
        ident "T",
        newIntLitNode(0),
      )
    )
  )
  p[2] = newNimNode(nnkGenericParams).add(newIdentDefs(ident "T", newEmptyNode()))
  p[p.len - 1] = objectConstructor
  result = newStmtList(p)
  echo result.repr
  echo result.treeRepr

#proc test2[T](): Generic[T] =
macroProc()

let g1 = test1[int]()
let g2 = test2[int]()