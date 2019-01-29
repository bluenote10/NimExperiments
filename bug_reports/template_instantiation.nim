type
  Data*[T] = object
    x: T

template test*[T](xxx: T) =
  #type TT = T
  let data = Data[T](x: xxx)

test(true)
