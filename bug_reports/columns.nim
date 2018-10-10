type
  Data*[T] = object
    data*: seq[T]

proc toSeq*[T](c: Data[T]): seq[T] =
  c.data
