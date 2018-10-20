import macros
import sequtils
import sugar

macro loop(types: typed): untyped =
  #echo types.treeRepr
  echo types.getType.treerepr
  echo types.getTypeImpl.repr
  echo types.getTypeInst.repr

  let typesNode = types.getType
  expectKind typesNode, nnkBracketExpr

  #[
  BracketExpr
    Sym "typeDesc"
    BracketExpr
      Sym "or"
      Sym "int"
      Sym "int8"
      Sym "int16"
      Sym "int32"
      Sym "int64"
      Sym "uint"
      Sym "uint8"
      Sym "uint16"
      Sym "uint32"
      Sym "uint64"
      Sym "float"
      Sym "float32"
      Sym "float"
  ]#

  echo typesNode[1][0].treerepr
  #doAssert typesNode[1][0] == bindSym"or"
  let subtypes = toSeq(types.getType[1])[1 .. ^1]

  for t in subtypes:
    echo t.repr

#loop(SomeNumber)


macro loopFunc(f: untyped): untyped =
  #echo types.treeRepr
  echo f.treerepr

loopFunc((x: SomeInteger) => (x*x).int)