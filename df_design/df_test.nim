
import times
import typetraits
import strutils
import sequtils
import future

# template to simplify timed execution
template runTimed(body: untyped) =
  let t1 = epochTime()
  body
  let t2 = epochTime()
  echo t2 - t1

#[
runTimed:
  var count = 1
  for line in lines "test_01.csv":
    count += 1
  echo count

type
  Schema[T] = object
    name: string

  IntCol = object
  FloatCol = object
]#

#[
type
  IntCol = object
  FloatCol = object

#var schema = [IntCol, IntCol, IntCol, IntCol, IntCol, FloatCol, FloatCol, FloatCol, FloatCol, FloatCol]
var schema = [IntCol(), FloatCol()]

echo schema.type.name
]#

type
  ColKind = enum
    IntCol,
    FloatCol
  Column = object
    kind: ColKind
    name: string

proc col(kind: ColKind, name: string): Column =
  Column(kind: kind, name: name)

var schema = [
  col(IntCol, "1"),
  col(IntCol, "2"),
  col(IntCol, "3"),
  col(IntCol, "4"),
  col(IntCol, "5"),
  col(FloatCol, "1"),
  col(FloatCol, "2"),
  col(FloatCol, "3"),
  col(FloatCol, "4"),
  col(FloatCol, "5"),
]

proc parse[N](s: string, schema: array[N, Column]) =
  discard

when false:
  iterator rawFileIterator*(filename: string): TaintedString {.inline.} =
    for line in lines "test_01.csv":
      yield line

  iterator schemaParsed*(iter: iterator(): string): string {.inline.} =
    for line in iter():
      yield line

  runTimed:
    var count = 1
    for line in lines "test_01.csv":
      count += 1
    echo count

  runTimed:
    var count2 = 1
    for line in rawFileIterator("test_01.csv"):
      count2 += 1
    echo count2

  when false:
    var count3 = 1
    for line in schemaParsed(rawFileIterator("test_01.csv")):
      count3 += 1
    echo count3



import macros

template parser[N](schema: array[N, Column]): untyped =
  proc customParser(s: string): int =
    result = 1

macro tupleBuilder[N](schema: array[N, Column]): untyped =
  # data: array[N, string],
  #result = quote do:
  #  (1, 2)
  #result = nnkPar(nnkIntLit(1), nnkIntLit(2), nnkPar(nnkIntLit(3)))
  #result = newPar(newIntLitNode(1))
  var parExpr = newPar()
  echo schema.len
  echo schema
  echo schema.repr
  echo schema.treeRepr
  for i in 0 ..< schema.len:
    let name = schema[i].name.toStrLit
    parExpr.add(newColonExpr(newIdentNode($name), newIntLitNode(1)))
  result = parExpr
  echo result.treeRepr

macro schemaParser[N](s: string, schema: array[N, Column]): untyped =
  #result = quote do:
  #  (1, 2)
  #result = nnkPar(nnkIntLit(1), nnkIntLit(2), nnkPar(nnkIntLit(3)))
  #result = newPar(newIntLitNode(1))
  var parExpr = newPar()
  parExpr.add(newColonExpr(newIdentNode("a"), newIntLitNode(1)))
  parExpr.add(newColonExpr(newIdentNode("b"), newIntLitNode(2)))
  result = parExpr
  echo result.treeRepr


const tinyschema = [
  col(IntCol, "A"),
  col(IntCol, "B"),
  col(FloatCol, "C")
]
#var x = tupleBuilder(["1", "2", "3"], tinyschema)
#echo x
echo tupleBuilder(tinyschema)

# var y: tuple[x: int] = (x: 1)
# echo y

when false:
  template schemaParser[N](schema: typed): untyped =
    let parser = proc (s: string): schema.T

proc range_interval (n:NimNode): seq[NimNode] {.compileTime.} =
    newSeq result,0
    if n.typeKind == ntyRange:
        #echo n.treerepr
        let a = n[1].intval.int
        let b = n[2].intval.int
        for i in a .. b:
            result.add newLit(i)
    elif n.typeKind == ntyEnum:
        assert n[0].kind == nnkEnumTy
        for f in n[0].children:
            result.add f
    else:
        echo treerepr(n)
        quit 1

macro asTuple* (obj: typed): untyped =
    let ty = obj.getType()
    if ty.typekind in {ntyArray, ntyArrayConstr}:
        let range_type = ty[1].getType
        let keys = range_interval(range_type)
        assert keys.len > 0

        result = newNimNode(nnkPar)
        for k in keys:
            result.add(quote do: `obj`[`k`])

    else:
        echo "unhandled type for asTuple()"
        echo obj.treerepr
        quit 1

    when true:
        echo result.treerepr
        echo result.repr

# echo asTuple([1,2,3])

macro generateParser*(schema: static[openarray[Column]]): untyped =
  #let returnType = newBracketExpr(newIdentNode(!"tuple"), newIdentNode(!"y"))
  #let returnType = newNimNode(nnkBracketExpr).add(ident("tuple"), newColonExpr(ident("x"), ident("int")))
  var returnType = newNimNode(nnkTupleTy)
  for col in schema:
    # TODO: This can probably done using true types + type.getType.name
    let typ = case col.kind
      of IntCol: "int"
      of FloatCol: "float"
    returnType.add(
      newIdentDefs(name = newIdentNode(col.name), kind = ident(typ))
    )
  echo returnType.treeRepr
  echo returnType.repr

  let test = quote do:
    let example2 = proc (s: string): tuple[A: int, B: int, C: float] =
      let fields = s.split(";")
      result.A = parseInt(fields[0])
      result.B = parseInt(fields[1])
      result.C = parseFloat(fields[2])
  echo test.treerepr
  echo test.repr

  let fieldsIdent = ident("fields")
  var body = quote do:
    let `fieldsIdent` = s.split(";")
  for i, col in schema.pairs:
    let parserFunc = case col.kind
      of IntCol: "parseInt"
      of FloatCol: "parseFloat"
    let ass_lhs = newDotExpr(ident("result"), ident(col.name))
    let ass_rhs = newCall(ident(parserFunc), newNimNode(nnkBracketExpr).add(ident("fields"), newIntLitNode(i)))
    body.add(newAssignment(ass_lhs, ass_rhs))
  echo body.treeRepr
  echo body.repr

  let params = [
    returnType,
    newIdentDefs(name = newIdentNode("s"), kind = newIdentNode("string"))
  ]
  result = newProc(params=params, body=body, procType=nnkLambda)
  echo result.treerepr
  echo result.repr


proc example(s: string): tuple[x: int, y: float] =
  let fields = s.split(";")
  result = (x: fields[0].parseInt, y: fields[1].parseFloat)

let example2 = proc (s: string): tuple[A: int, B: int, C: float] =
  let fields = s.split(";")
  result.A = parseInt(fields[0])
  result.B = parseInt(fields[1])
  result.C = parseFloat(fields[2])


let testproc = generateParser(tinyschema)
let parsed = testproc("1;2;3")
echo parsed

# https://nim-lang.org/docs/tut2.html
# https://github.com/nim-lang/Nim/issues/3559
# https://forum.nim-lang.org/t/1513#9440




macro staticArrayTest(arr: static[openarray[string]]): untyped =
  #result = newIntLitNode(arr.len)
  var parExpr = newPar()
  for i in 0 ..< arr.len:
    parExpr.add(newColonExpr(newIdentNode("Col" & $i), newStrLitNode(arr[i])))
  result = parExpr
  #echo result.treeRepr

const arr1 = ["A", "B"]
const arr2 = @["A", "B"]
echo staticArrayTest(arr1)
echo staticArrayTest(arr2)

