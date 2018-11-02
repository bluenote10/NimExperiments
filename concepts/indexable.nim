import typetraits

type
  Indexable*[T] = concept c
    # somehow infer the index type
    type Index = type(c.low)
    c.high is Index
    var i: Index
    c[i] is T
    c[i] is var T
    var val: T
    c[i] = val
    c.len is int

when false:
  proc test[T](x: T) =
    when T is Indexable:
      echo "x is Indexable"
      echo type(x[0])
    when T is Indexable[int]:
      echo "x is Indexable[int]"

  test(newSeq[int]())
  test([[1, 2], [3, 4]])
  test(@[[1, 2], [3, 4]])
  test([@[1, 2], @[3, 4]])
  test(@[@[1, 2], @[3, 4]])


when false:
  proc test1[T](s: Indexable[T]) =
    echo s.low, " ", s.high
    for x in s:
      echo x
    for i in s.low ..< s.high:
      echo s[i]
    for i in 0 .. s.len:
      echo s[i]

  proc test2[T](s: openarray[T]) =
    echo s.low, " ", s.high
    for x in s:
      echo x
    for i in s.low ..< s.high:
      echo s[i]
    for i in 0 .. s.len:
      echo s[i]

  let t: array[5..10, int] = [1, 2, 3, 4, 5, 6]
  #test1(t)
  test2(t)

when true:
  type
    MyEnum = enum
      A, B

  proc test[T](s: Indexable[T]) =
    for i in s.low .. s.high:
      echo s[i]

  let t: array[MyEnum, int] = [1, 2]
  test(t)
  test(@[1, 2, 3])
  test(array[5..10, int]([1, 2, 3, 4, 5, 6]))