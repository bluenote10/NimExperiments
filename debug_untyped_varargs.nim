import macros

macro addFields*(t: typed, fields: varargs[untyped]): untyped =
  echo fields.len
  echo fields.repr
  echo fields.treeRepr
  # actual implementation omitted
  result = quote do: `t`

let t = (x: 1.0, y: 1.0)

# not using colon expressions work:
echo t.addFields(works, withPlain, expressions)

# not using method call syntax works
echo addFields(t, length: sqrt(t.x^2 + t.y^2))

# fails in combination
echo t.addFields(length: sqrt(t.x^2 + t.y^2))

