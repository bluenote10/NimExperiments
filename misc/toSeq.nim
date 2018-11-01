
template toSeq*(collection: expr, sizeHint: int): expr {.immediate.} =
  var result {.gensym.}: seq[type(collection)] =
    newSeq[type(collection)](sizeHint)
  var i = 0
  for x in collection:
    result[i] = x
    inc i
  result


let a = [1,2,3,4]
let s = a.items.toSeq(a.len)
echo s


#proc toSeqWithHint[T](collection: T) =