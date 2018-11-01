import times
import typetraits
import strutils
import sequtils
import future
import macros


type
  ColKind = enum
    IntCol,
    FloatCol
  Column = object
    kind: ColKind
    name: string

proc col(kind: ColKind, name: string): Column =
  Column(kind: kind, name: name)


macro schemaParser*(schema: static[openarray[Column]]): untyped =
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
  when defined(checkMacros):
    echo returnType.treeRepr
    echo returnType.repr

  let test = quote do:
    let example2 = proc (s: string): tuple[A: int, B: int, C: float] =
      let fields = s.split(";")
      result.A = parseInt(fields[0])
      result.B = parseInt(fields[1])
      result.C = parseFloat(fields[2])
  when defined(checkMacros):
    echo test.treerepr
    echo test.repr

  let fieldsIdent = ident("fields")
  let expectedFields = newIntLitNode(schema.len)
  var body = quote do:
    let `fieldsIdent` = s.split(";")
    if `fieldsIdent`.len != `expectedFields`:
      raise newException(IOError, "Unexpected number of fields")
  for i, col in schema.pairs:
    let parserFunc = case col.kind
      of IntCol: "parseInt"
      of FloatCol: "parseFloat"
    let ass_lhs = newDotExpr(ident("result"), ident(col.name))
    let ass_rhs = newCall(ident(parserFunc), newNimNode(nnkBracketExpr).add(ident("fields"), newIntLitNode(i)))
    body.add(newAssignment(ass_lhs, ass_rhs))
  when defined(checkMacros):
    echo body.treeRepr
    echo body.repr

  let params = [
    returnType,
    newIdentDefs(name = newIdentNode("s"), kind = newIdentNode("string"))
  ]
  result = newProc(params=params, body=body, procType=nnkLambda)
  when defined(checkMacros):
    echo result.treerepr
    echo result.repr


# from: https://github.com/def-/nim-iterutils/blob/master/src/iterutils.nim
template toClosure*(i): auto =
  ## Wrap an inline iterator in a first-class closure iterator.
  iterator j: type(i) {.closure.} =
    for x in i:
      yield x
  j

proc repeat*[T](value: T, n: int = -1): iterator(): T =
  ## .. code-block:: Nim
  ##   repeat(5) -> 5; 5; 5; 5; ...
  ##   repeat(5,n=2) -> 5; 5
  result = iterator(): T {.closure.} =
    var i = 0
    while n == -1 or i < n:
      yield value
      i += 1

proc lineIter*(filename: string): iterator(): string =
  result = iterator(): string {.closure.} =
    for line in lines(filename):
      yield line

iterator linesC*(filename: string): string {.closure.} =
  ## Iterates over any line in the file named `filename`.
  ##
  ## If the file does not exist `EIO` is raised. The trailing newline
  ## character(s) are removed from the iterated lines. Example:
  ##
  ## .. code-block:: nim
  ##   import strutils
  ##
  ##   proc transformLetters(filename: string) =
  ##     var buffer = ""
  ##     for line in filename.lines:
  ##       buffer.add(line.replace("a", "0") & '\x0A')
  ##     writeFile(filename, buffer)
  var f = open(filename, bufSize=8000)
  #defer: close(f)
  var res = TaintedString(newStringOfCap(80))
  while f.readLine(res): yield res


# from: https://github.com/petermora/nimLazy/blob/master/lazy.nim
proc len*[T](iter: iterator(): T): int =
  ## .. code-block:: Nim
  ##   len(a;b;c;d) -> 4
  discard iter()
  while not finished(iter):
    result += 1
    discard iter()


proc map*[T,S](iter: iterator(): T, f: (proc(any: T): S) ): iterator(): S =
  ## .. code-block:: Nim
  ##   map(1;2;3;4;5, f) -> f(1);f(2);f(3);f(4);f(5)
  result = iterator(): S {.closure.}=
    var x = iter()
    while not finished(iter):
      yield f(x)
      x = iter()


when isMainModule:
  template runTimed(body: untyped) =
    let t1 = epochTime()
    body
    let t2 = epochTime()
    echo t2 - t1

  const schema = [
    col(IntCol, "C1"),
    col(IntCol, "C2"),
    col(IntCol, "C3"),
    col(IntCol, "C4"),
    col(IntCol, "C5"),
    col(FloatCol, "C6"),
    col(FloatCol, "C7"),
    col(FloatCol, "C8"),
    col(FloatCol, "C9"),
    col(FloatCol, "C10"),
  ]
  let parser = schemaParser(schema)

  runTimed:
    block:
      var count = 0
      for line in lines "test_01.csv":
        count += 1
      echo count

  runTimed:
    block:
      var count = 0
      #for line in toClosure(lines("test_01.csv"))():
      #  count += 1
      echo count

  runTimed:
    block:
      var count = 0
      #let lineIter = lineIter("test_01.csv")
      #for line in lineIter():
      #var iter = linesC # ("test_01.csv")
      #for line in linesC("test_01.csv").map(parser):
      for line in linesC("test_01.csv"):
        count += 1
      echo count




iterator infinite(): int {.closure.} =
  var i = 0
  while true:
    yield i
    inc i

iterator take[T](it: iterator (): T, numToTake: int): T {.closure.} =
  var i = 0
  for x in it():
    if i >= numToTake:
      break
    yield x
    inc i

let inf2 = infinite.take(10)
for x in inf2.take(5):
  echo x
