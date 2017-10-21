import macros

type
  AnyType = ref object of RootObj
  Typed[T] = ref object of AnyType
    x: T

template easyCast(a: AnyType, T: typedesc): Typed[T] =
  cast[Typed[T]](a)

macro multiImpl(a: AnyType, varname: untyped, types: untyped, procBody: untyped): untyped =
  result = newIfStmt()
  for t in types:
    let elifBranch = newNimNode(nnkElifBranch)
    let cond = infix(a, "of", newNimNode(nnkBracketExpr).add(bindSym"Typed", t))
    let body = newStmtList()
    body.add(newLetStmt(varname, newCall(bindSym"easyCast", a, t)))
    body.add(procBody)
    elifBranch.add(cond)
    elifBranch.add(body)
    result.add(elifBranch)
  result = newStmtList(result)
  echo result.repr

proc procTyped[T](t: Typed[T]) =
  echo t.x

proc procDynamicallyTyped*(a: AnyType) =
  multiImpl(a, aTyped, [int16, int32, int64]):
    aTyped.procTyped()

# The codegen works though, when writing the result of the macro manually:
proc procDynamicallyTypedManual*(a: AnyType) =
  if a of Typed[int16]:
    let aTyped = easyCast(a, int16)
    aTyped.procTyped()
  elif a of Typed[int32]:
    let aTyped = easyCast(a, int32)
    aTyped.procTyped()
  elif a of Typed[int64]:
    let aTyped = easyCast(a, int64)
    aTyped.procTyped()
