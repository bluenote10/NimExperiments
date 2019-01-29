import macros

proc f(x = 1) =
  echo x

macro x(i: int): untyped =
  result = newNimNode(nnkExprEqExpr)
  result.add(newIdentNode("x"))
  result.add(i)
  echo result.repr
  echo result.treeRepr

f(x = 2)
#f(x(2))

macro fullAst(i: int): untyped =
  result = newCall(newIdentNode("f"))
  result.add(newNimNode(nnkExprEqExpr))
  result[1].add(newIdentNode("x"))
  result[1].add(i)
  echo result.repr
  echo result.treeRepr

#fullAst(1)


macro y(i: int): untyped =
  result = newNimNode(nnkExprColonExpr)
  result.add(newIdentNode("y"))
  result.add(i)
  echo result.repr
  echo result.treeRepr

type
  Obj = object
    y: int

let a = Obj(y: 1)
let b = Obj(y(1))

#let arr = {1: x}
#echo arr


#f(t(2))
#f(last("test"), a="b", other=1)


#[
proc f(a = "a", last: string, other: int) =
  echo "a = ", a
  echo "last = ", last
  echo "other = ", other


macro last(s: string): untyped =
  result = newNimNode(nnkExprEqExpr)
  result.add(newIdentNode("last"))
  result.add(s)
  echo result.repr
  echo result.treeRepr


#f(last="test", a="b", other=1)
f(last("test"), a="b", other=1)
]#