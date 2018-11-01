echo "Test"



type
  TestCol*[T] = object
    data*: seq[T]


converter testColToSeq[T](t: TestCol[T]): seq[T] = t.data

converter testColToSeq[T](t: var TestCol[T]): var seq[T] = t.data

#converter testColToSeq[T](t: TestCol[T]): openarray[T] = t.data


#proc len*(b: TestCol): int = b.data.len

#proc `[]`*[T](b: TestCol[T], idx: int): T =
#  b.data[idx]

#proc `[]=`*[T](b: var TestCol[T], idx: int, item: T) =
#  b.data[idx] = item

var x = newSeq[int](3)
x[0] = 42

var y = TestCol[int](data: x)

echo y.len

y[0] = 1
y[1] = 2
y[2] = 3

#for n in map(y, proc (x: int): int = x + 1):
#  echo($n)
