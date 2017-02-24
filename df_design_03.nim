import macros
import typeinfo
import future

type
  DataFrame = ref object of RootObj

  AstMapper = ref object of DataFrame
    mapper: NimNode

template newAstMapper(n: NimNode) = # {.dirty.} =
  AstMapper(mapper: n)

proc myFunc(x: int) =
  echo "test"

macro map(df: DataFrame, mapper: untyped): untyped =
  echo getImpl(!"myFunc").repr
  echo mapper.repr
  #echo mapper.name
  echo callsite().repr
  result = getAst(newAstMapper(mapper))
  echo result.repr
  #result = quote do:
  #  AstMapper(mapper: mapper)


let df = DataFrame()
let df2 = df.map(x * 2)
#map(df, x * 2)


