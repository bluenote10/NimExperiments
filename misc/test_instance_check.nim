import typeinfo

type
  TestBase = ref object of RootObj

  DerivedA = ref object of TestBase
  DerivedB[T] = ref object of TestBase
    field: T

proc testProc(x: TestBase) =
  var xCopy = x
  echo "testing:"
  var xAny = toAny(xCopy[])
  echo xAny.kind
  for f, val in xAny.fields:
    echo f, val

let a: TestBase = DerivedA()
let b: TestBase = DerivedB[int](field: 1)

testProc(a)
testProc(b)


var bExpl = DerivedB[int](field: 1)
var xAny = toAny(bExpl[])
echo "base = ", xAny.base
echo "kind = ", xAny.kind
for f, val in xAny.fields:
  echo f, val
