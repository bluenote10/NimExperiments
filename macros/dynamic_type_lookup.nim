import macros
import typetraits
import sequtils
import tables

proc getTypeInfo*(T: typedesc): pointer =
  var dummy: T
  getTypeInfo(dummy)
  

#[
proc runWithTypesOuter(a: pointer) =
  discard
  echo a.repr
  # how to lookup the type that corresponds to `a`
  # and invoke runWithTypesInner?


proc runWithTypesInner(A: typedesc) =
  discard


runWithTypesOuter(getTypeInfo(int))
]#

macro wrapTyped(args: varargs[untyped]): untyped =
  let procName = args[0]
  let typeSymbols = toSeq(args)[1 .. args.len-2]
  let body = args[args.len - 1]
  echo procName.repr
  echo typeSymbols.repr
  echo body.repr

  template registerAst() =
    var registered = initTable[(pointer, pointer), pointer]()

    proc register(X: typedesc, Y: typedesc) =


wrapTyped(run, A, B):
  var a: A
  var b: B


# run(getTypeInfo(int), getTypeInfo(string))