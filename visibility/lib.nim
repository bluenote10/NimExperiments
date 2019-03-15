import macros

# The lib provides a definition of an abstract base type
# without any actual instantiations...
type
  Element* = ref object of RootObj
    # Example for a field that should be an implementation
    # detail, used only internally in `lib`. It should
    # neither be public nor should there be getter/setter
    # so that we can rely on the fact that it does not
    # change after construction.
    id: string

proc run*(elements: openarray[Element]) =
  for element in elements:
    echo "Touching element: " & $element[]

when true:
  macro verifyObjectConstructor(x: typed): untyped =
    if x.kind != nnkObjConstr:
      error($x.repr[0..^1] & " is not an object constructor")

  template newElement*(idString: string, constructor: typed): untyped =
    verifyObjectConstructor(constructor)
    let element = constructor
    element.id = idString
    element

when false:
  template privateInitializer(element: typed, idString: string): untyped =
    element.id = idString
    element

  macro newElement*(T: typedesc, id: string, args: varargs[untyped]): untyped =
    # convert varargs into an object constructor call of T
    let constructor = newTree(nnkObjConstr)
    constructor.add(T.getTypeInst[1])
    for arg in args:
      expectKind(arg, nnkExprEqExpr)
      constructor.add(newColonExpr(arg[0], arg[1]))
    # apply post construction initialization of parent fields
    result = newCall(bindSym"privateInitializer", constructor, id)
    echo result.repr
