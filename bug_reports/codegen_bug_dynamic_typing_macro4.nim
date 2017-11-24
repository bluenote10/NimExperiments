import macros

template injectSymbolInBlocks(varname: untyped, procBody: untyped): untyped =
  block:
    let `varname` {.inject.} = 1
    procBody
  block:
    let `varname` {.inject.} = 1
    procBody

proc templateVersion() =
  injectSymbolInBlocks(a):
    echo a

templateVersion()