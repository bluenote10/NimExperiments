import macros

macro m(body: untyped): untyped =
  body

let x = m()