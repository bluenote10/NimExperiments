# This is an example how an abstract syntax tree could be modelled in Nim
type
  NodeKind = enum  # the different node types
    nkInt,          # a leaf with an integer value
    nkFloat,        # a leaf with a float value
    nkString,       # a leaf with a string value
    nkAdd,          # an addition
    nkSub,          # a subtraction
    nkIf            # an if statement
  Node = ref NodeObj
  NodeObj = object
    case kind: NodeKind  # the ``kind`` field is the discriminator
    of nkInt: intVal: int
    of nkFloat: floatVal: float
    of nkString: strVal: string
    of nkAdd, nkSub:
      leftOp, rightOp: Node
    of nkIf:
      condition, thenPart, elsePart: Node

# create a new case object:
var n = Node(kind: nkIf, condition: nil)
# accessing n.thenPart is valid because the ``nkIf`` branch is active:
n.thenPart = Node(kind: nkFloat, floatVal: 2.0)

# the following statement raises an `FieldError` exception, because
# n.kind's value does not fit and the ``nkString`` branch is not active:
#n.strVal = ""

# invalid: would change the active object branch:
#n.kind = nkInt

case n.kind
of nkInt:
  echo n.intVal
of nkIf:
  echo n.condition.repr
  echo n.intVal
else:
  echo "other"

var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                          rightOp: Node(kind: nkInt, intVal: 2))
# valid: does not change the active object branch:
x.kind = nkSub