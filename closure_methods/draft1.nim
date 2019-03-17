#[
Design goals:
- All fields should be guaranteed to be initialized.
- All methods should be guaranteed to be initialized.
- Super calls should be possible.
- overrides should be explicitly marked.
- automatically inheriting base method should require no code.
]#

#[
Questions:
- What is the easiest way to inherit a parent method?
- Are discardable methods possible?
- Is there a different in terms of namespace compared to
  methods?
- Does splitting into modules affect it?
]#

proc debug*[T](x: T) {.importc: "console.log", varargs.}

{.experimental: "notnil".}

type
  Base = ref object of RootObj
    getState*: (proc(): int) not nil
    x*: int

  Sub = ref object of Base
    subMethod*: (proc(x: int): int) not nil


proc newBase(): Base =
  # private members don't have to be part of object fields
  var privateState = 0

  # public members are tricky, because we cannot capture
  # them via a closure and pass them to the object constructor

  #[
  Option 1: We ditch the `not nil` methods and construct `self`
  at the top of the scope, prefix everything with `self`
  and add the closures at the end? Probably we could still
  ensure complete initialization within the macro logic.
  Pros:
    - clearer scoping
    - we only close over `self`
  Cons:
    - No way to differentiate between mutable/immutable state?
      Maybe wait for a general solution:
      https://github.com/nim-lang/RFCs/issues/100
    - BIGGEST ISSUE: We pollute the scope of the classes and
      if the base class has field of type `x` the subclasses,
      the subclasses cannot redefine `x`. This would applies
      even to private fields, leading to serious scoping
      issues. Also, there is the issue that constructing
      the subclasses also initialized all the (private)
      fields of the base class, but we do not really get
      a chance to properly calling the constructor of the
      base class to initialize the private fields. So the
      pattern `let base = newBase()` mixes composition with
      inheritance. The instance of `base` has all internal
      fields properly initialized. But since the `self`
      instance inherits from base, it duplicates the
      internal fields itself, but leaving them unitialized.

      Could this be solved by wrapping all fields into
      a gensymed `impl` field? Seems messy, because we
      would have to forward field access then as well.

      This may be a strong argument why the fields should
      actually be the public methods only. This way the
      object scope only contains what it really has to.
  ]#

  #[
  General scoping question:
    Should all fields (private/public) be prefixed by `self`?
    Maybe that's better, because than the variable scope is clearer,
    and a local `x` in a method doesn't accidentally hide the `x`
    field. On the other hand this could still be left as a decision
    for the user. If they want to wrap the whole state into a
    `state` field they can opt out of the flat scoping, but this
    would again make it impossible to differentiate which fields
    of `state` are mutable/immutable.
  ]#

  # Option 2: Public fields are forbidden and instead we provide
  # a mechanism for easily providing getter/setter to internal
  # variables.
  # Pros:
  #   - easy differentiation between mutable/immutable variables
  #   - the fields block would have standard syntax:
  #     `let x = 1` vs the awkward `x = 1` (or `self.x = 1`)
  # Cons:
  #   - More verbose syntax: getX() + setX(value)
  #   - Function call overhead (template, inline proc?)
  #   - Scoping. UPDATE: Maybe we could still introduce a `self`
  #     variable, which is a named tuple containing all fields
  #     and methods combined. Drawback: type checking on `self`
  #     could be a surprise...
  #   - If we inject `base` anyway, it would be more consistent
  #     to inject `self` as well.
  #   - Less idiomatic Nim?
  var x = 0

  # same goes for private methods
  proc inc(x: int): int = x + 1

  # definitions of public methods
  proc getState(): int =
    privateState = inc(privateState)
    x = inc(privateState)
    privateState

  Base(getState: getState, x: x)


proc newSub(): Sub =
  var privateState = cstring"state"

  proc subMethod(x: int): int =
    x + 1

  let base = newBase()
  Sub(
    getState: base.getState,
    x: base.x,
    subMethod: subMethod
  )

proc newSubWithSelf(): Sub =
  let base = newBase()
  var self = (
    privateState: 1,
    getState: base.getState, # if not overloaded
    #subMethod: subMethod, not really possible, because
    # it has to close over self... We could again split
    # it into nil initialzation, method definitions which
    # close over self, assigning the methods in the end...
    subMethod: proc (x: int): int{.closure.} = nil,
  )

  proc subMethod(x: int): int =
    self.privateState += 1
    x + 1

  self.subMethod = subMethod

let b = newBase()
debug(b.getState())
debug(b.x)
debug(b.getState())
debug(b.x)
debug(b.getState())
debug(b.x)

#let s = newSubWithSelf()
