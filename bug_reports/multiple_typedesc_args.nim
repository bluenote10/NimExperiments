proc aProc(A: typedesc) =
  var a: A

template aTemplate(A: typedesc) =
  var a: A

var T: typedesc[int]
aProc(int)       # works with concrete type
aTemplate(int)   # works with concrete type
aProc(T)         # works with typedesc variable
aTemplate(T)     # fails with typedesc variable

when false:
  template single(A: typedesc) =
    type AA = A 
    var a: type(AA)

  template double(A: typedesc, B: typedesc) = 
    var a: A
    var b: B

  var T: typedesc[int]
  single(int)
  single(T)
  double(int, int)
  double(T, T)


when false:
  template t(A: typedesc, B: typedesc) = 
    #proc p(x: A, y: B) =    
    #  discard
    var a: A
    var b: B

  proc pro(A: typedesc, B: typedesc) =
    discard

  t(float, float)

  var T: typedesc[float]
  #t(T, T)

  #pro(T, T)
