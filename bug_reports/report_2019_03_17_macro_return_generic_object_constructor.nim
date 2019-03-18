import macros

type
  Generic[T] = ref object of RootObj
    x: T

# The macro below generates this code, which compiles fine directly
proc test1[T](x: T): Generic[T] =
  Generic[T](x: x)

# Let's dump its tree
dumpTree:
  proc test1[T](x: T): Generic[T] =
    Generic[T](x: x)

# Now the macro
macro generateConstructor(returnType, body: untyped): untyped =
  # Get the constructors procDef
  var procDef = body[0]
  # Generate an object constructor Node
  let objectConstructor = newNimNode(nnkObjConstr).add(
    returnType,
    newNimNode(nnkExprColonExpr).add(
      ident "x",
      ident "x",
    )
  )
  let procBody = newStmtList(objectConstructor)
  # Patch the constructor return type -- this seems to be problematic
  procDef[3][0] = returnType
  # Set the proc body
  procDef[procDef.len - 1] = procBody

  result = newStmtList(procDef)
  echo result.repr
  echo result.treeRepr

generateConstructor(Generic[T]):
  proc test2[T](x: T)

let g1 = test1[int](42)
let g2 = test2[int](42)


when false:
  macro genObjConstructor(returnType): untyped =
    result = newNimNode(nnkObjConstr).add(returnType)

  proc test2[T](): Generic[T] =
    genObjConstructor(Generic[T])

