import macros

when false:
  proc extractFields(n: NimNode): seq[string] =
    # extract fields present in given tuple
    result = newSeq[string]()
    echo n.treeRepr
    for child in n.children:
      if child.kind != nnkIdentDefs:
        error "addFields expects a tuple or object, consisting of nnkIdentDefs children."
      else:
        let field = child[0] # first child of IdentDef is a Sym corresponding to field name
        result.add($field)


  macro mergedType(ta, tb: typed): untyped =
    #result = newNimNode(nnkTupleTy)

    echo ta.treeRepr
    echo tb.treeRepr
    echo ta.getTypeInst.treeRepr
    echo tb.getTypeInst.treeRepr
    echo ta.getTypeImpl.treeRepr
    echo tb.getTypeImpl.treeRepr
    
    let fieldsA = extractFields(ta)
    let fieldsB = extractFields(tb)
    echo fieldsA
    echo fieldsB
    
    #result.add(
    #  newIdentDefs(name = newIdentNode(col.name), kind = typ)
    #)
    
    result = ident("int")



  macro mergeGeneric[T1, T2](a: T1, b: T2): untyped =
    result = ident("int")


  proc mergedTuple[T1, T2](a: T1, b: T2): mergedType(T1, T2) =
    discard

  proc mergedTuple2[T1, T2](a: T1, b: T2): auto =
    result = a.age.mergedType(a, b)

  macro mergeGenericWrapper(a, b: typed): untyped =
    result = ident("int")


  let t1 = (name: "A", age: 99)
  let t2 = (name: "A", height: 1.80)

  echo mergedTuple2(t1, t2)


when false:


  proc extractFields(n: NimNode): seq[string] =
    # extract fields present in given tuple
    result = newSeq[string]()
    echo n.treeRepr
    for child in n.children:
      if child.kind != nnkIdentDefs:
        error "addFields expects a tuple or object, consisting of nnkIdentDefs children."
      else:
        let field = child[0] # first child of IdentDef is a Sym corresponding to field name
        result.add($field)

  macro mergeTupleMacro(ta, tb: typed): untyped =

    echo ta.treeRepr
    echo tb.treeRepr
    echo ta.getTypeInst.treeRepr
    echo tb.getTypeInst.treeRepr
    echo ta.getTypeImpl.treeRepr
    echo tb.getTypeImpl.treeRepr
    
    let fieldsA = extractFields(ta.getTypeImpl)
    let fieldsB = extractFields(tb.getTypeImpl)
    echo fieldsA
    echo fieldsB
    
    result = newPar()
    let fieldExpr = newDotExpr(ta, ident("name"))
    result.add(
      newColonExpr(ident "name", fieldExpr)
    )
    echo result.repr


  proc mergeTuple[A, B](a: seq[A], b: seq[B]): auto =
    let t = mergeTupleMacro(a[0], b[0])
    result = @[t]


  let t1 = (name: "A", age: 99)
  let t2 = (name: "A", height: 1.80)

  echo mergeTuple(@[t1], @[t2])

  when false:
    echo mergeTuple[
      tuple[name: string, age: int],
      tuple[name: string, height: float],
      tuple[name: string]
    ](@[t1], @[t2])



when true:

  import tables

  proc extractFields(n: NimNode): OrderedTable[string, NimNode] =
    # extract fields present in given tuple
    result = initOrderedTable[string, NimNode]()
    # echo n.treeRepr
    for child in n.children:
      if child.kind != nnkIdentDefs:
        error "extractFields expects a tuple or object, consisting of nnkIdentDefs children."
      else:
        let fname = child[0]
        let ftype = child[1]
        result[$fname] = ftype

  macro determineType(ta, tb: typed, on: static[openarray[string]]): untyped =

    #[
    echo ta.treeRepr
    echo tb.treeRepr
    echo ta.getTypeInst.treeRepr
    echo tb.getTypeInst.treeRepr
    echo ta.getTypeImpl.treeRepr
    echo tb.getTypeImpl.treeRepr
    ]#

    # getTypeImpl returns something like:
    # BracketExpr
    #   Sym "typeDesc"
    #   TupleTy
    # So we need child at index 1 to get the tuple/object type
    let fieldsA = extractFields(ta.getTypeImpl[1])
    let fieldsB = extractFields(tb.getTypeImpl[1])
    echo "Fields in A:"
    for key, val in fieldsA:
      echo "    ", key, " -> ", val.repr
    echo "Fields in B:"
    for key, val in fieldsB:
      echo "    ", key, " -> ", val.repr

    result = newNimNode(nnkTupleTy)
    for field in on:
      if not (field in fieldsA):
        error "Operand A does not have required field: " & field
      elif not (field in fieldsB):
        error "Operand B does not have required field: " & field
      elif fieldsA[field] != fieldsB[field]:
        error "Operands do not have same type\n" &
              "Type of field '" & field & "' in operand A: " & fieldsA[field].repr & "\n" &
              "Type of field '" & field & "' in operand B: " & fieldsB[field].repr
      else:
        result.add(
          newIdentDefs(name=ident(field), kind=fieldsA[field])
        )

    for field, ftype in fieldsA:
      if not (field in on):
        if field in fieldsB:
          result.add(
            newIdentDefs(name=ident(field & "_a"), kind=ftype)
          )
        else:
          result.add(
            newIdentDefs(name=ident(field), kind=ftype)
          )

    for field, ftype in fieldsB:
      if not (field in on):
        if field in fieldsA:
          result.add(
            newIdentDefs(name=ident(field & "_b"), kind=ftype)
          )
        else:
          result.add(
            newIdentDefs(name=ident(field), kind=ftype)
          )

  macro joinTuple(a: tuple, b: tuple, on: static[openarray[string]]): untyped =

    let fieldsA = extractFields(a.getTypeImpl)
    let fieldsB = extractFields(b.getTypeImpl)

    result = newNimNode(nnkPar)
    for field in on:
      if not (field in fieldsA):
        error "Operand A does not have required field: " & field
      elif not (field in fieldsB):
        error "Operand B does not have required field: " & field
      elif fieldsA[field] != fieldsB[field]:
        error "Operands do not have same type\n" &
              "Type of field '" & field & "' in operand A: " & fieldsA[field].repr & "\n" &
              "Type of field '" & field & "' in operand B: " & fieldsB[field].repr
      else:
        let dotExpr = newDotExpr(a, ident(field))
        result.add(
          newColonExpr(ident(field), dotExpr)
        )

    for field, ftype in fieldsA:
      if not (field in on):
        var fieldName = field
        if field in fieldsB:
          fieldName &= "_a"
        let dotExpr = newDotExpr(a, ident(field))
        result.add(
          newColonExpr(ident(fieldName), dotExpr)
        )

    for field, ftype in fieldsB:
      if not (field in on):
        var fieldName = field
        if field in fieldsA:
          fieldName &= "_b"
        let dotExpr = newDotExpr(b, ident(field))
        result.add(
          newColonExpr(ident(fieldName), dotExpr)
        )
    echo result.repr
    
  macro tupleMatches(a: tuple, b: tuple, on: static[openarray[string]]): untyped =
    let fieldsA = extractFields(a.getTypeImpl)
    let fieldsB = extractFields(b.getTypeImpl)
    result = newNimNode(nnkPar)
    for field in on:
      if not (field in fieldsA):
        error "Operand A does not have required field: " & field
      elif not (field in fieldsB):
        error "Operand B does not have required field: " & field
      else:
        let exprA = newDotExpr(a, ident(field))
        let exprB = newDotExpr(b, ident(field))
        result.add(
          infix(exprA, "==", exprB)
        )
    # echo result.repr

  proc join*[A, B](seqA: seq[A], seqB: seq[B], on: static[openarray[string]]): auto =
    result = newSeq[determineType(A, B, on)]()
    for a in seqA:
      for b in seqB:
        let matches = tupleMatches(a, b, on)
        echo "a = ", a, " b = ", b, " matches => ", matches
        if matches:
          result.add(joinTuple(a, b, on))

  proc joinGenericReturn*[A, B, C](seqA: seq[A], seqB: seq[B], on: static[openarray[string]]): seq[C] =
    result = newSeq[C]()
    for a in seqA:
      for b in seqB:
        let matches = tupleMatches(a, b, on)
        echo "a = ", a, " b = ", b, " matches => ", matches
        if matches:
          result.add(joinTuple(a, b, on))

  macro joinMacro*[A, B](seqA: seq[A], seqB: seq[B], on: static[openarray[string]]): untyped =
    #[
    dumpTree:
      joinGenericReturn[A, B, C](seqA, seqB, on)
    #result = newCall(bindsym"joinGenericReturn", seqA, seqB, on)
    let resultType = determineType(A, B, on)
    let genericBracket = newNimNode(nnkBracketExpr)
    genericBracket.add(seqA)
    genericBracket.add(seqB)
    genericBracket.add(resultType)
    result = newNimNode(nnkCall)
    result.add(genericBracket)
    echo result.repr
    ]#
    result = quote do: discard

  let a1 = (name: "A", age: 99, complex: (re: 1.0, im: 2.0))
  let b1 = (name: "A", height: 1.80)
  let b2 = (name: "A", height: 1.50)
  let b3 = (name: "B", height: 1.50)

  let joined = join(@[a1], @[b1, b2, b3], ["name"])
  for x in joined:
    echo x

