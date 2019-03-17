import macros
import strformat


proc parseDefinition(n: NimNode): tuple[identClass: NimNode, genericParams: NimNode] =
  if n.kind == nnkIdent:
    return (n, newEmptyNode())
  elif n.kind == nnkBracketExpr:
    let identClass = n[0]
    let genericParams = newNimNode(nnkGenericParams)
    for i in 1 ..< n.len:
      genericParams.add(
        newIdentDefs(n[i], newEmptyNode(), newEmptyNode())
      )
    return (identClass, genericParams)
  else:
    error &"Cannot parse class definition: {n.repr}"


proc findBlock(n: NimNode, name: string): NimNode =
  var found = newSeq[NimNode]()
  for child in n:
    if child.kind == nnkCall and child[0].kind == nnkIdent and child[0].strVal == name:
      found.add(child)
  if found.len == 0:
    error &"Could not find a section of type '{name}'"
  if found.len == 2:
    error &"There are {found.len} sections of type '{name}'; only one section allowed."
  return found[0][1]


proc convertProcdefIntoField(procdef: NimNode): NimNode =
  result = newIdentDefs(
    procdef[0],
    newNimNode(nnkProcTy).add(
      procdef[3], # copy formal params
      newEmptyNode(),
    )
  )



proc parseProcDefs(n: NimNode): (NimNode, seq[NimNode]) =
  var nCopy = n.copyNimTree()
  var exportedMethods = newSeq[NimNode]()

  for procDef in nCopy:
    if procDef.kind == nnkDiscardStmt:
      continue
    elif procDef.kind != nnkProcDef:
      error &"Section 'procs' must only contain proc definitions, but got: {procDef.kind}"
    else:
      if procDef[0].kind == nnkPostfix and procDef[0][0].strVal == "*":
        # get rid of postfix export "*"
        procDef[0] = procDef[0][1]
        exportedMethods.add(convertProcdefIntoField(procDef))

  return (nCopy, exportedMethods)


macro class*(definition, body: untyped): untyped =
  result = newStmtList()
  echo definition.treeRepr
  echo body.treeRepr

  # extract infos from definition
  let parsedDefinition = parseDefinition(definition)
  let identClass = parsedDefinition.identClass
  let identInheritFrom = ident"RootObj"

  # extract blocks and fields
  let constructorBlock = findBlock(body, "constructor")
  let varsBlock = findBlock(body, "vars")
  let procsBlock = findBlock(body, "procs")

  let (procsBlockTransformed, exportedMethods) = parseProcDefs(procsBlock)
  let fields =
    if exportedMethods.len == 0:
      newEmptyNode()
    else:
      let reclist = newNimNode(nnkRecList)
      for exportedMethod in exportedMethods:
        reclist.add(exportedMethod)
      reclist

  # build type section
  let typeSection = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef).add(
    parsedDefinition.identClass,
    parsedDefinition.genericParams,
    newNimNode(nnkRefTy).add(
      newNimNode(nnkObjectTy).add(
        newEmptyNode(),
        newNimNode(nnkOfInherit).add(
          identInheritFrom
        ),
        fields,
      )
    )
  )
  typeSection.add(typeDef)

  let constructorDef = constructorBlock[0]  # TODO: find ProcDef, check only 1
  # We inject the return type to the ctor proc as a convenience.
  # Return type is at: FormalParams at index 3, return type at index 0.
  # Note that we have to use the original definition node, not just
  # the identClass, because we need a BracketExpr in case of generics.
  constructorDef[3][0] = definition

  # Assembly class body
  let procBody = newStmtList()
  for statement in varsBlock:
    procBody.add(statement)
  for statement in procsBlockTransformed:
    procBody.add(statement)

  # Add final object constructor as return value of procBody
  let returnValue = newNimNode(nnkObjConstr)
  returnValue.add(definition)    # the return type -- we again need the BracketExpr for generics
  for exportedMethod in exportedMethods:
    let exportedMethodIdent = exportedMethod[0]
    # add the `method: method` expression
    returnValue.add(newNimNode(nnkExprColonExpr).add(
      exportedMethodIdent,
      exportedMethodIdent
    ))
  procBody.add(returnValue)

  # Add the class body
  constructorDef[constructorDef.len - 1] = procBody

  result.add(typeSection)
  result.add(constructorDef)

  echo result.repr
  #echo result.treeRepr