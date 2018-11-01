import macros

#[
macro iterateFields2(t: tuple): untyped =
  let tup = (a: 1, b: 2)
  for field, ftype in fieldPairs(tup):
    echo "Iterating field: " & field & " -> " & ftype.type
]#

macro iterateFields*(t: typed): untyped =
  echo "--------------------------------"

  # check type of t
  var tTypeImpl = t.getTypeImpl
  if tTypeImpl.isNil:
    error "No type impl available"
  else:
    echo "okay"
  echo tTypeImpl.len
  echo tTypeImpl.kind
  echo tTypeImpl.typeKind
  echo tTypeImpl.treeRepr

  case tTypeImpl.typeKind:
  of ntyTuple:
    # For a tuple the IdentDefs are top level, no need to descent
    discard
  of ntyObject:
    # For an object the children are
    # - pragmas (=> typically Empty)
    # - parent (=> typically Empty)
    # - nnkRecList, which contains the IdentDefs we are looking for
    tTypeImpl = tTypeImpl[2]
  else:
    error "Not a tuple or object"

  # iterate over fields
  for child in tTypeImpl.children:
    if child.kind == nnkIdentDefs:
      let field = child[0] # first child of IdentDef is a Sym corresponding to field name
      let ftype = child[1] # second child is type
      echo "Iterating field: " & $field & " -> " & $ftype
    else:
      echo "Unexpected kind: " & child.kind.repr


type
  TestObj = object
    x: int
    y: int
    name: string

let t = (x: 0, y: 1, name: "")
let o = TestObj(x: 0, y: 1, name: "")

iterateFields(t)
iterateFields(o)
