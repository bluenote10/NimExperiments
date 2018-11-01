

when false:
  import macros


  discard """
  macro asTuple*[T](arr: openarray[T]): expr =

    #result = newNimNode(nnkPar)
    #for k in keys:
    #  result.add(quote do: `obj`[`k`])
    for x in arr:
      echo x
    echo arr.treerepr, arr.size
    result = newNimNode(nnkPar)
  """


  macro genTuple[T](arity: int): expr =
    #result = newStmtList()
    #idents = newIdentDefs()
    echo arity.treeRepr
    var pars = newPar()
    echo pars.treerepr
    for i in 0 ..< arity.intVal:
      #pars.add(newIdent("int"))
      #pars.add(bindSym"int")
      pars.add(T.getType)
      echo i

    echo "Pars:\n"
    echo pars.treerepr
    result = pars


  dumptree:
    var t: (int, int, int)



  proc toTuple[T](arr: openarray[T], arity: static[int]) =
    echo arr.repr
    #let t = genTuple(5)
    let a = arr.len
    var t: genTuple[T](arity)
    echo "t = ", t
    for i in 0 ..< arr.len:
      #t[i] = x
      echo i, arr[i]#, t[i]
      #t[i] = arr[i]
    echo "tuple = ", t
    #var t: tuple

  discard """
  proc toTuple[T](arr: openarray[T]) {.compileTime.} =
    echo arr.repr
    #let t = genTuple(5)
    let a = arr.len
    var t: genTuple(a)
    echo "t = ", t
    #var t: tuple
  """

  let s = @["a", "b", "c"]

  #s.toTuple[seq[string], 3]
  #toTuple[seq[string], 3](s)
  #s.toTuple(3)
  #
  s.toTuple(3)



when false:
  import tuples
  import macros

  macro genTuple[T](arity: int): expr =
    #result = newStmtList()
    #idents = newIdentDefs()
    echo arity.treeRepr
    var pars = newPar()
    echo pars.treerepr
    for i in 0 ..< arity.intVal:
      #pars.add(newIdent("int"))
      #pars.add(bindSym"int")
      pars.add(T.getType)
      echo i

    echo "Pars:\n"
    echo pars.treerepr
    result = pars

  proc toTuple[T](arr: openarray[T], t: var tuple) =
    var sub = newSeq[T](arr.len-1)
    for i in 1 ..< arr.len:
      sub[i-1] = arr[i]
    echo sub
    #result = (arr[0], toTuple(sub))
    t = (arr[0], arr[1])


  let s = @["X", "Y", "Z"]

  #s.toTuple[seq[string], 3]
  #toTuple[seq[string], 3](s)
  #s.toTuple(3)
  #
  #let t = s.toTuple
  #echo t
  #

  #var t: (string, string)
  #var t: genTuple[string](2)

  #dumptree:
    #var t: (string, string)


  #toTuple(s, t)

import macros

macro extract(args: varargs[untyped]): typed =
  ## assumes that the first expression is an expression
  ## which can take a bracket expression. Let's call it
  ## `arr`. The generated AST will then correspond to:
  ##
  ## let <second_arg> = arr[0]
  ## let <third_arg>  = arr[1]
  ## ...
  result = newStmtList()
  # the first vararg is the "array"
  let arr = args[0]
  var i = 0
  # all other varargs are now used as "injected" let bindings
  for arg in args.children:
    if i > 0:
      var rhs = newNimNode(nnkBracketExpr)
      rhs.add(arr)
      rhs.add(newIntLitNode(i-1))

      let assign = newLetStmt(arg, rhs) # could be replaced by newVarStmt
      result.add(assign)
    i += 1
  #echo result.treerepr


let s = @["X", "Y", "Z", "1", "2", "3"]

s.extract(a, b, c)
# this essentially produces:
# let a = s[0]
# let b = s[1]
# let c = s[2]

# check if it works:
echo a, b, c

block: 
  s.extract(a, b, _, _, _, x)
  echo a, b, x



