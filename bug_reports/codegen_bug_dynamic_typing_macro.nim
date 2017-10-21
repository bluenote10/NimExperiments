import future
import sequtils
import strutils
import typetraits
import macros

type
  Column* = ref object of RootObj

  TypedCol*[T] = ref object of Column
    arr*: seq[T]

template assertType(c: Column, T: typedesc): TypedCol[T] =
  cast[TypedCol[T]](c)

macro multiImpl(c: Column, cTyped: untyped, types: untyped, procBody: untyped): untyped =
  echo c.treeRepr
  echo types.treeRepr
  echo procBody.treeRepr
  result = newIfStmt()
  for t in types:
    echo t.treeRepr
    let elifBranch = newNimNode(nnkElifBranch)
    let cond = infix(c, "of", newNimNode(nnkBracketExpr).add(bindSym"TypedCol", t))
    let body = newStmtList()
    body.add(newLetStmt(cTyped, newCall(bindSym"assertType", c, t)))
    body.add(procBody)
    elifBranch.add(cond)
    elifBranch.add(body)
    result.add(elifBranch)
  result = newStmtList(result)
  echo result.repr

proc sum*[T](c: TypedCol[T]): float =
  var sum = 0.0
  for x in c.arr:
    sum += x.float
  return sum

proc sum*(c: Column): float =
  multiImpl(c, cTyped, [int16, int32, int64, float32, float64]):
    return cTyped.sum()
