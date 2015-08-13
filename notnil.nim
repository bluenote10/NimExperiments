
import sequtils

type
  SafeSeq[T] = seq[T] not nil

when true:
  proc newSafeSeq*[T](size: int): SafeSeq[T] =
    #result = newSeq[T](size)
    result = @[]
    result.setlen(size)

  proc proveNotNil*[T](a: seq[T]): SafeSeq[T] =
    if a != nil:
      result = a # cannot prove 'a' is not nil
    else:
      raise newException(ValueError, "can't convert")

  let s = newSafeSeq[int](100)
  echo s.len

block:
  let s = @[1,2,3]

block:
  let a = @[1,2,3]
  let b: SafeSeq[int] = a

when false:
  block:
    let a = @[1,2,3]
    let b: SafeSeq[int] = a.mapIt(int, it + 1)

when false:
  block:
    var a: seq[int]
    let b: SafeSeq[int] = a

when false:
  let a: SafeSeq[int] = @[1,2,3]
  let b: SafeSeq[string] = a.mapIt(string, $it)

when true:
  let a: SafeSeq[int] = @[1,2,3]
  let b: SafeSeq[string] = a.mapIt(string, $it).proveNotNil


when false:
  block:
    let s: SafeSeq[int] = newSeq[int](100)


