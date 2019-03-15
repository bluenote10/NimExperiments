proc debug*[T](x: T) {.importc: "console.log", varargs.}

type
  Base = ref object of RootObj
    commonField: int

  # Apparently object get the `m_type` prop as soon
  # as they are inheritable, i.e., ref object of RootObj
  NormalRefObject = ref object
    m_type2: int
  InheritableRefObject = ref object of RootObj
    m_type2: int

  # And there is a bug: using a field named `m_type` leads
  # to code gen like this: {m_type: NTI71026, m_type: 0}

  A = ref object of Base
  B = ref object of Base
  C = ref object of Base

method render(self: Base) {.base.} =
  debug cstring"render base"

method render(self: A) =
  debug cstring"render A"

method render(self: B) =
  debug cstring"render B"


proc takesObj(x: Base) =
  if x of A:
    debug cstring"it's an A"
  elif x of B:
    debug cstring"it's a B"
  elif x of C:
    debug cstring"it's a C"
  x.render()

takesObj(A())
takesObj(B())
takesObj(C())

debug(Base())
debug(NormalRefObject())
debug(InheritableRefObject())

# Aha, even these object have an `m_type`
import dom
let element = Element()
debug(element)
# But that's because the object has been constructed on Nim side.
# If we get an Element from e.g. the browser createElement the
# type checks would just fail.

# Test: can we force a type on something that is missing `m_type`
import jsffi
let x = JsObject{commonField: 0}
debug(cstring"x = ", x)
let y = x.to(A)
debug(cstring"y = ", y)

# I can't see a difference between using .importc. or not.
type
  WithImportC {.importc.} = ref object of RootObj
    x: int
    s: cstring

  WithoutImportC = ref object of RootObj
    x: int
    s: cstring

debug(WithImportC())
debug(WithoutImportC())

{.experimental: "notnil".}

type
  SomeProc = proc(a: int): int

  BaseFields = ref object of RootObj
    run*: proc() not nil

  AA = ref object of BaseFields
    other*: (proc(a: int): int) not nil   # note parens required to avoid "invalid type"
    #other*: SomeProc not nil
    #x: int
  BB = ref object of BaseFields


proc aa(): AA =
  AA(
    run: (proc() = echo "test"),    # parens required to avoid "complex statement requires indentation"
    other: proc(a: int): int = a + 1,
    #x: 1
  )

proc bb(): BB =
  BB(
    run: proc() = echo "test"
  )

proc takesBaseFields(x: BaseFields) =
  debug(x.run())

#takesBaseFields(BaseFields())
takesBaseFields(aa())
takesBaseFields(bb())