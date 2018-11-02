import typetraits
import macros

template underlyingType[T](x: T): typedesc =
  type(items(x))

macro getGeneric(x: typedesc, i: int): untyped =
  #echo x
  #echo "type: ", x.getType.treerepr
  #echo "typeinst: ", x.getTypeInst.treerepr
  echo "\n *** typeimpl:\n", x.getTypeImpl.treerepr

  let typeDesc = x.getTypeImpl
  expectKind typeDesc, nnkBracketExpr

  if typeDesc.len != 2:
    error "Expected typedesc of length two, but got: " & typeDesc.treeRepr

  if typeDesc[0].kind != nnkSym or typeDesc[0].strVal != "typeDesc":
    error "Expected first child to be 'sym typeDesc', but got: " & typeDesc.treeRepr

  let typ = typeDesc[1]
  expectKind typ, nnkBracketExpr

  #let iInt: int = i.intVal
  let iVal = i.intVal.int
  if typ.len < iVal + 2:
    error "Type only has " & $(typ.len-1) & " generic parameters, index " & $iVal & " is out of bounds"

  # echo typ.treerepr
  # echo typ[iVal + 1].treerepr

  #template wrapType(x) =
  #  typedesc[x]

  result = typ[iVal + 1]
  #result = getAst(wrapType(typ[iVal + 1]))
  echo "result => ", result.treeRepr


type
  Object[T] = object
    x: T

proc test[T](x: T) =

  when x is openarray:
    echo "its openarray"
  when x is seq:
    echo "its seq, underlyingType: ", underlyingType(x)
    echo "generic 0: ", getGeneric(T, 0)
  when x is array:
    echo "its array, underlyingType: ", underlyingType(x)
    echo "generic 0: ", getGeneric(T, 0)
    echo "generic 1: ", getGeneric(T, 1)

  when x is openarray[bool]:
    echo "its openarray[bool]"
  when x is seq[bool]:
    echo "its seq[bool]"
  when x is array[1, bool]:
    echo "its array[1, bool]"
  when x is array[2, bool]:
    echo "its array[2, bool]"
  when x is array[3, bool]:
    echo "its array[3, bool]"
  when x is seq | array and underlyingType(x) is bool:
    echo "this works"

test([true, false])
test(@[true, false])

block:
  let o = Object[string]()
  var t: type[getGeneric(type(o), 0)]
  echo "Underlying type of object: ", getGeneric(type(o), 0)

block:
  let o = Object[Object[int]]()
  var t: type[getGeneric(type(o), 0)]
  #echo "Underlying type of object: ", getGeneric(type(o), 0)

