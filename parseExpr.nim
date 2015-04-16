import macros

proc isValidExpr(s: string): bool {.compileTime.}=
  try:
    var x = parseExpr(s)
    return true
  except ValueError:
    return false


echo "1 + 1".isValidExpr    
