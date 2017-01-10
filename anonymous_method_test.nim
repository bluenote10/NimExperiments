

proc nested() = # yeah, returning nested types doesn't work obviously

  type
    NestedT = object
      N: int

  proc name(n: NestedT): seq[int] = @[1, 2, 3]

  var n = NestedT(N: 1)
  echo n.name

  # result = n