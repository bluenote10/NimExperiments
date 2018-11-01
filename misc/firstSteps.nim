var s1 = "hello"
var s2 = "\0\0\0\0"

var s3 = s1 & s2
echo s3.len
echo s3.repr

when false:
  echo "Hello"

  include sub/other

  proc test[T](x: T) =
    var y = x.someFunc
    echo "Test: " & $x & $y

  proc someFunc(x: int): int =
    ($x).len

  proc someFunc(s: string): int =
    s.len

  test(1)
  test("asdf")


  type Foo[T] = object
      bar: T

  var my_foo = Foo[string](bar: "foobar")

  # This works!
  proc test[T](f: Foo, n: int): T = 
      f.bar

  proc testB(f: Foo, n: int): Foo.T = 
      f.bar

  echo test(my_foo, 1)
  echo testB(my_foo, 1)


  # This fails!
  proc test2[T](f: Foo[T], n: int): seq[T] =
      var s: T = f.bar
      var r: seq[T] = @[] 
      for x in 1..n:
          r.add(s)
      result = r 

  echo test2(my_foo, 3)



import typetraits

proc takesTuple(t: tuple) =
  echo repr(t)
  ##echo t.len
  #echo t.type.name
  #echo t.type.arity
  for f in t.fields:
    echo f
    #echo repr(f.type)
    echo repr(f.type.name)

var
  t = (1, "Test", (1,2,3), 3.14)

takesTuple(t)
