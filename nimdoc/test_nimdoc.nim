import macros

proc aRegularProc*() =
  ## A regular proc 
  discard


template genTemplatedProc*() =
  ## Docstring of template -- not exporting it makes this a module docstring

  proc aTemplateProc*() =
    ## A template proc
    discard

genTemplatedProc()


macro genMacroProc*(): untyped =
  ## Docstring of macro
  
  template genProcAst() =
    proc aMacroProc*() =
      ## A macro proc

  let ast = getAst(genProcAst())
  echo ast.treeRepr
  result = ast

genMacroProc()


proc test(): int =
  42
  ##

test()