import macros
import strformat
import options


iterator items*[T](o: Option[T]): T =
  if o.isSome:
    yield o.get


type
  ClassDef = ref object
    rawClassDef: NimNode
    identClass: NimNode
    genericParams: NimNode
    identBaseClass: NimNode


proc parseClassName(classDef: ClassDef, n: NimNode) =
  ## Helper function to split the class ident from generic params
  if n.kind == nnkIdent:
    classDef.identClass = n
    classDef.genericParams = newEmptyNode()
  elif n.kind == nnkBracketExpr:
    let identClass = n[0]
    let genericParams = newNimNode(nnkGenericParams)
    for i in 1 ..< n.len:
      genericParams.add(
        newIdentDefs(n[i], newEmptyNode(), newEmptyNode())
      )
    classDef.identClass = identClass
    classDef.genericParams = genericParams
  else:
    error &"Cannot parse class definition: {n.repr}"


proc parseDefinition(n: NimNode): ClassDef =
  result = ClassDef()
  if n.kind == nnkInfix and n[0].strVal == "of":
    result.rawClassDef = n[1]
    result.parseClassName(n[1])
    result.identBaseClass = n[2]
  else:
    result.rawClassDef = n
    result.parseClassName(n)
    result.identBaseClass = ident "RootObj"


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


proc findBlockOpt(n: NimNode, name: string): Option[NimNode] =
  var found = newSeq[NimNode]()
  for child in n:
    if child.kind == nnkCall and child[0].kind == nnkIdent and child[0].strVal == name:
      found.add(child)
  if found.len > 1:
    error &"There are {found.len} sections of type '{name}'; only zero/one sections allowed."
  elif found.len == 0:
    return none(NimNode)
  else:
    return some(found[0][1])


proc convertProcdefIntoField(procdef: NimNode): NimNode =
  # We need to turn funcName into funcName* for export
  let procIdent = procdef[0]
  let field = newNimNode(nnkPostfix).add(
    ident "*",
    procIdent,
  )
  let fieldType = newNimNode(nnkProcTy).add(
    procdef[3], # copy formal params
    newEmptyNode(),
  )
  result = newIdentDefs(field, fieldType)


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


macro my*(t: typedesc): untyped =
  #echo t.treeRepr
  echo "1: ", t.getTypeInst.treeRepr
  echo "2: ", t.getTypeInst[1].symbol.getImpl.treeRepr


#[
macro iterateFields*(t: typedesc): untyped =
  echo "--------------------------------"

  # check type of t
  let tNode: NimNode = t
  echo t.treeRepr
  var tTypeImpl = getTypeImpl(t[1])
  echo tTypeImpl.len
  echo tTypeImpl.kind
  echo tTypeImpl.typeKind
  echo tTypeImpl.treeRepr

  echo "--------------------------------"
  error "here"
]#


proc classImpl(definition, base, body: NimNode): NimNode =

  # echo getType(base).treerepr
  # echo getTypeInst(base).treerepr
  # echo getTypeImpl(base).treerepr
  # echo base.getTypeInst[1].symbol.getImpl.treeRepr

  result = newStmtList()
  echo definition.treeRepr
  echo body.treeRepr

  # extract infos from definition
  let classDef = parseDefinition(definition)

  # extract blocks and fields
  let constructorBlock = findBlock(body, "constructor")
  let varsBlock = findBlock(body, "vars")
  let procsBlock = findBlock(body, "procs")
  let baseBlockOpt = findBlockOpt(body, "base")

  # get base TypeDef
  let baseTypeDef = base.getTypeInst[1].symbol.getImpl
  echo baseTypeDef.treeRepr
  let baseObjectTy = baseTypeDef[2][0]
  let baseRecList = if baseObjectTy.len >= 3: baseObjectTy[2] else: newEmptyNode()
  var baseMethods = newSeq[string]()
  for identDef in baseRecList:
    if identDef.kind == nnkIdentDefs:
      let nameNode = identDef[0]
      let typeNode = identDef[1]
      if nameNode.kind == nnkPostfix and nameNode.len == 2: # because of export * symbol
        baseMethods.add(nameNode[1].strVal)
        echo nameNode[1].strVal
    else:
      error &"Expected nnkIdentDefs, got {identDef.repr}"

  # create type fields from exported methods
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
    classDef.identClass,
    classDef.genericParams,
    newNimNode(nnkRefTy).add(
      newNimNode(nnkObjectTy).add(
        newEmptyNode(),
        newNimNode(nnkOfInherit).add(
          classDef.identBaseClass
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
  # For now we make the injection optional, because of a macro bug
  # in Nim that prevents injecting the type with generics.
  if constructorDef[3][0].kind == nnkEmpty:
    constructorDef[3][0] = classDef.rawClassDef

  # Assembly class body
  let procBody = newStmtList()
  for baseBlock in baseBlockOpt:
    let baseValue = baseBlock[0]
    procBody.add(newNimNode(nnkLetSection).add(
      newIdentDefs(ident "base", newEmptyNode(), baseValue)
    ))
  for statement in varsBlock:
    procBody.add(statement)
  for statement in procsBlockTransformed:
    procBody.add(statement)

  # Add final object constructor as return value of procBody
  let returnValue = newNimNode(nnkObjConstr)
  returnValue.add(classDef.rawClassDef)    # the return type -- we again need the BracketExpr for generics
  for exportedMethod in exportedMethods:
    let exportedMethodIdent = exportedMethod[0][1]
    # add the `method: method` expression
    returnValue.add(newNimNode(nnkExprColonExpr).add(
      exportedMethodIdent,
      exportedMethodIdent
    ))
  for baseMethod in baseMethods:
    let exportedMethodIdent = ident(baseMethod)
    let exportedMethodValue = newDotExpr(ident "base", ident(baseMethod))
    # add the `method: method` expression
    returnValue.add(newNimNode(nnkExprColonExpr).add(
      exportedMethodIdent,
      exportedMethodValue
    ))

  procBody.add(returnValue)

  # Add the class body
  constructorDef[constructorDef.len - 1] = procBody

  result.add(typeSection)
  result.add(constructorDef)

  echo result.repr
  #echo result.treeRepr


#[
macro class*(definition: untyped, body: untyped): untyped =
  let base = newEmptyNode()
  result = classImpl(definition, base, body)
]#

macro class*(definition: untyped, base: typed, body: untyped): untyped =
  #echo "1: ", base.getTypeInst.treeRepr
  #echo "2: ", base.getTypeInst[1].symbol.getImpl.treeRepr
  result = classImpl(definition, base, body)
