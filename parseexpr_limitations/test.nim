import macros

macro parse(e: string): untyped =
  result = parseExpr($e)

block:
  let x = 1
  echo parse("x")

block:
  proc test(x: int) =
    echo parse("x")
  test(1)

block:
  template test(x: int) =
    echo parse("x")
  test(1)

block:
  template test(x: int) =
    let xLocal {.inject.} = x
    echo parse("xLocal")
  test(1)