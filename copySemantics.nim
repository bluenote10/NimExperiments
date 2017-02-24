import strutils

proc genHugeSeq(): seq[int] =
  result = newSeq[int](10)#_000_000)

proc seqAddr*[T](s: seq[T]): pointer =
  echo "s.addr         = ", s.unsafeAddr.repr
  echo "s[].addr       = ", cast[pointer](s).repr
  echo "s[0].addr      = ", cast[pointer](s[0].unsafeAddr).repr
  if not isNil(s):
    result = s[0].unsafeAddr
  else:
    result = nil

template checkSeq(name: string, s: untyped) =
  #stdout.write name & "[]       --> ", cast[pointer](s).repr
  let reprStr = cast[pointer](s[0].unsafeAddr).repr.strip(chars=Newlines)
  stdout.write name & "[0]      --> ", reprStr
  echo " => [", s[0], ", ", s[1], ", ", s[2], "]"

template isSameAddr(s1: untyped, s2: untyped) =
  echo "Address: ", if cast[pointer](s1) == cast[pointer](s2): "SAME" else: "DIFFERENT"


type
  SomeType = ref object
    huge: seq[int]


proc testPureSeqs() =
  echo "\n *** Checking pure seqs"

  block:
    echo "let a = ...\nlet b = a"
    let a = genHugeSeq()
    let b = a
    checkSeq("a", a)
    checkSeq("b", b)
    isSameAddr(a, b)

  block:
    echo "var a = ...\nlet b = a"
    var a = genHugeSeq()
    let b = a
    a[0] = 1
    checkSeq("a", a)
    checkSeq("b", b)
    isSameAddr(a, b)

  block:
    echo "let a = ...\nvar b = a"
    let a = genHugeSeq()
    var b = a
    b[0] = 1
    checkSeq("a", a)
    checkSeq("b", b)
    isSameAddr(a, b)

  block:
    echo "var a = ...\nvar b = a"
    var a = genHugeSeq()
    var b = a
    a[0] = 1
    b[0] = 2
    checkSeq("a", a)
    checkSeq("b", b)
    isSameAddr(a, b)


proc testRefObject() =
  echo "\n *** Checking ref object"

  block:
    echo "let a = ...\nlet b = a"
    let a = SomeType(huge: genHugeSeq())
    let b = a
    checkSeq("a", a.huge)
    checkSeq("b", b.huge)
    isSameAddr(a.huge, b.huge)

  block:
    echo "var a = ...\nlet b = a"
    var a = SomeType(huge: genHugeSeq())
    let b = a
    a.huge[0] = 1
    checkSeq("a", a.huge)
    checkSeq("b", b.huge)
    isSameAddr(a.huge, b.huge)

  block:
    echo "let a = ...\nvar b = a"
    let a = SomeType(huge: genHugeSeq())
    var b = a
    b.huge[0] = 1
    checkSeq("a", a.huge)
    checkSeq("b", b.huge)
    isSameAddr(a.huge, b.huge)

  block:
    echo "var a = ...\nvar b = a"
    var a = SomeType(huge: genHugeSeq())
    var b = a
    a.huge[0] = 1
    b.huge[0] = 2
    checkSeq("a", a.huge)
    checkSeq("b", b.huge)
    isSameAddr(a.huge, b.huge)


testPureSeqs()
testRefObject()


proc checkAsParam(x: SomeType): pointer =
  let reprStr = cast[pointer](x.huge[0].unsafeAddr).repr.strip(chars=Newlines)
  stdout.write "<arg>     --> ", reprStr
  echo " => [", x.huge[0], ", ", x.huge[1], ", ", x.huge[2], "]"
  result = x.huge[0].unsafeAddr
  when compiles do:
    x.huge[0] = 1:
      echo "Modification: direct"
      x.huge[0] = 1
  else:
    echo "Modification: requires copy"
    var copy = x
    copy.huge[0] = 1
  when compiles do:
    x = SomeType(huge: @[1, 2, 3]):
      echo "Can even update parameter"

proc checkAsVarParam(x: var SomeType): pointer =
  let reprStr = cast[pointer](x.huge[0].unsafeAddr).repr.strip(chars=Newlines)
  stdout.write "<arg>     --> ", reprStr
  echo " => [", x.huge[0], ", ", x.huge[1], ", ", x.huge[2], "]"
  result = x.huge[0].unsafeAddr
  x.huge[0] = 1
  # Note that if x is a var ref, we can even point to something entire different:
  # x = SomeType(huge: @[1, 2, 3])


proc testFunctionCalls() =
  echo "\n Checking function calls"

  block:
    echo "let a = ... [regular parameter]"
    let a = SomeType(huge: genHugeSeq())
    let pointer = checkAsParam(a)
    checkSeq("a", a.huge)
    echo "Address: ", if pointer == cast[pointer](a.huge[0].unsafeAddr): "SAME" else: "DIFFERENT"

  block:
    echo "var a = ... [regular parameter]"
    var a = SomeType(huge: genHugeSeq())
    let pointer = checkAsParam(a)
    checkSeq("a", a.huge)
    echo "Address: ", if pointer == cast[pointer](a.huge[0].unsafeAddr): "SAME" else: "DIFFERENT"

  block:
    echo "var a = ... [regular parameter]"
    var a = SomeType(huge: genHugeSeq())
    let pointer = checkAsVarParam(a)
    checkSeq("a", a.huge)
    echo "Address: ", if pointer == cast[pointer](a.huge[0].unsafeAddr): "SAME" else: "DIFFERENT"

testFunctionCalls()



