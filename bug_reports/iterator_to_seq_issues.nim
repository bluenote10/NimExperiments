#import sequtils
import tables

#import columns
proc toSeq*[T](x: seq[T]): seq[T] =
  x

let t = initOrderedTable[int, int]()
let k = keys(t)
#let s = toSeq(keys(t))
#echo s
