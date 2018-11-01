import macros

macro usesGetTypeImpl*(t: typed): untyped =
  var tTypeImpl = t.getTypeImpl
  var tTypeInst = t.getTypeInst
  echo tTypeImpl.treeRepr
  echo tTypeInst.treeRepr
  result = quote do: discard

usesGetTypeImpl((0, 0.0, ""))
