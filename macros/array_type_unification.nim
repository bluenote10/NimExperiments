import macros

type
  Base = ref object of RootObj
  A = ref object of Base
  B = ref object of Base

proc makeA(): A = A()
proc makeB(): B = B()

proc f1(a: openarray[cstring]) =
  echo a

proc f2(a: openarray[Base]) =
  echo a.len

#template fixString(a: openarray[string])

template fixBaseType(x: typed): untyped =
  when compiles(x.Base):
    x.Base
  else:
    x

proc fixArraysImpl(n: NimNode): NimNode =
  if n.kind == nnkBracket:
    #result = n.copyNimTree
    result = n.copyNimTree
    for i in 0 ..< n.len:
      result[i] = newCall(ident"fixBaseType", fixArraysImpl(result[i]))
  elif n.kind == nnkStrLit:
    result = newCall(ident"cstring", n)
  else:
    result = n.copyNimTree
    for i in 0 ..< n.len:
      result[i] = fixArraysImpl(result[i])


macro fixArrays(body: untyped): untyped =
  echo " * Input:", body.treeRepr
  result = fixArraysImpl(body)
  echo " * Output:", result.repr

fixArrays:
  f1(["a", "b"])
  f2([A()])
  f2([makeA(), makeB()])
  let a = @[makeA(), makeB()]
  echo a.type
  f2(a)