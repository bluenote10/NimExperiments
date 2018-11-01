

type
  Test = object

var t = Test()
echo t

discard """
type
  Schema[N: static[int]] = object

var s = Schema[10]()
echo s
"""

when false:
  type
    Matrix[S: static[seq[string]]] = object
      M: int

  proc check[S: static[seq[string]]](m: Matrix[S]): Matrix[S] =
    echo m
    for x in m.S:
      echo x

  template project(s: seq[string], c: string): untyped =
    #var newS = newSeq[string]()
    #for x in s:
    #  newS.add(x)
    #newS
    @["X", "Y"]

  proc remove[S: static[seq[string]]](m: Matrix[S], c: static[string]): Matrix[project(S, c)] =
    #for x in S1:
    #  echo x
    # const S3 = S
    result = Matrix[project(S, c)](M: 0)

  template addAccessors[S: static[seq[string]]](m: Matrix[S]): untyped =
    for x in S:
      proc `x`(m: Matrix[S]) =
        echo "yes"


  const s = @["A", "B", "C"]
  var m = Matrix[s](M: 0)
  echo check(m)

  #addAccessors(m)
  #m.`x`()

  var m2 = remove(m, "A")
  echo check(m2)


when true:

  type
    Column[T] = seq[T]
    DataFrame {.inheritable.} = object

  type
    MySchema = object of DataFrame
      id: Column[int]
      name: Column[string]
      info: Column[string]

    

