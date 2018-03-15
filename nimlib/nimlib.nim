
proc nimfunc*(x: float): float {.cdecl, exportc, dynlib.} =
  result = 42