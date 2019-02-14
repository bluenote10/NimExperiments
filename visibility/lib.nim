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

template newElement*(idString: string, body: typed): untyped =
  let element = body
  element.id = idString
  element