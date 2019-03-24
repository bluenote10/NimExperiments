import closure_methods

when false:
  class(Base, RootObj):
    constructor:
      proc newBase*()

    vars:
      discard

    procs:
      proc abstract*() =
        echo "abstract base"

      proc templateMethod*() =
        abstract()

  block:
    let x = newBase()
    x.templateMethod()


  class(Sub of Base, Base):
    constructor:
      proc newSub*()

    vars:
      discard

    procs:
      proc abstract*() =
        echo "abstract sub"


  block:
    let x = newBase()
    x.templateMethod()


when false:
  class(BasePingPong, RootObj):
    constructor:
      proc newBasePingPong*()

    vars:
      discard

    procs:
      proc ping*() =
        echo "ping"
        pong()

      proc pong*() =
        echo "pong"
        ping()

  block:
    let x = newBasePingPong()
    x.ping()


when false:
  type
    BasePingPong = ref object of RootObj
      ping: proc()
      pong: proc()

  proc newBasePingPong(): BasePingPong =

    var procsPublic: tuple[ping: proc(), pong: proc()]
    var procsPrivate: tuple[private: proc()]

    template pong() = procsPublic.pong()
    template ping() = procsPublic.ping()
    template private() = procsPrivate.private()

    procsPublic.ping = proc() =
      echo "ping"
      private()
      pong()

    procsPublic.pong = proc() =
      echo "pong"
      private()
      ping()

    procsPrivate.private = proc() =
      echo "private"

    BasePingPong(ping: procsPublic.ping, pong: procsPublic.ping)

  block:
    let x = newBasePingPong()
    x.ping()

# -----------------------------------------------------------------------------
# setInstance
# -----------------------------------------------------------------------------

when false:
  type
    RootObjRef = ref RootObj

  type
    Base = ref object of RootObj
      setInstance*: proc(instance: RootObjRef)
      abstract*: proc()
      templateMethod*: proc()

  proc newBase(): Base =

    var self = Base()

    template abstract() = self.abstract()

    self.setInstance = proc(instance: RootObjRef) =
      self = instance.Base

    self.abstract = proc() =
      echo "abstract [base]"

    self.templateMethod = proc() =
      echo "template Method [base]"
      abstract()

    self

  block:
    let x = newBase()
    x.templateMethod()


  type
    Sub = ref object of Base
      #setInstance2*: proc(instance: Sub)

  proc newSub(): Sub =

    var self = Sub()
    let base = newBase()
    base.setInstance(self.RootObjRef)

    template abstract() = self.abstract()

    self.setInstance = proc(instance: RootObjRef) =
      self = instance.Sub

    self.abstract = proc() =
      echo "abstract [sub]"

    self.templateMethod = base.templateMethod

    self

  block:
    let x = newSub()
    x.templateMethod()


# -----------------------------------------------------------------------------
# Via constructors?
# -----------------------------------------------------------------------------

when false:

  type
    Base = ref object of RootObj
      abstract*: proc()
      templateMethod*: proc()

  proc newBaseImpl(self: Base, xInit: int) =

    var x = xInit

    template abstract() = self.abstract()

    self.abstract = proc() =
      echo "abstract [base]"

    self.templateMethod = proc() =
      echo "template Method [base]"
      echo "x = ", x
      abstract()

  proc newBase(xInit: int): Base =
    var self = Base()
    newBaseImpl(self, xInit)
    self


  block:
    let x = newBase(10)
    x.templateMethod()


  type
    Sub = ref object of Base

  proc newSubImpl(self: Sub) =
    template abstract() = self.abstract()

    var base = Base(abstract: self.abstract, templateMethod: self.templateMethod)

    self.abstract = proc() =
      base.abstract()
      echo "abstract [sub]"

  proc newSub(): Sub =
    var self = Sub()
    newBaseImpl(self, 20)
    newSubImpl(self)
    self

  block:
    let x = newSub()
    x.templateMethod()


#[

Is it possible to inject a `base` identifier to explicitly call
methods on the base type?
- Seems possible via explicitly constructing a Base type based
  on all the initial `self` function pointers before the subclass
  patches them.

Can we omit holding the state of the base class?
- It should be possible: If the macro sees that a class patches
  _all_ the functions of a base class **and** does not use
  explicit calls to base.methods, we could omit the patchBase(self)
  line (where the base would waste memory).

  Its probably easier to make that dependent on whether the user
  specifies a base class call.
  - If it is there, the base class is instantiated and the user
    can call it.
  - If it is omitted and the subclass doesn't implement all
    methods, the macro could error.
  - If it is omitted and the subclass does implement all methods
    but the user tries to call `base.someMethod` they get the
    usual compiler error because base does not exist, which
    is not surprising without the base initialization call.

How would a user indicate that they don't want to allocate base?
- By omitting the base call? The macro could check that all
  methods are overloaded and omit exposing the `base` symbol.

Can we indicate that a method is abstract just from its TypeDef?
- Make the field private, because it must not be called from outside?
  No, doesn't make sense, because subclasses that implement the
  abstract function cannot change it to a public field.

Should we go for newBase(...) + patchBase(self: Base, ...) constructors or the
new style `init(T: typedesc[Base], ...)` + `patch(T: typedesc[Base], self: Base, ...)`?
- Maybe for the actual constructor we allow the user to pass in anything because
  than they can chose what is the public interface of their class.
- The question remains how we find the right patch functions for a given base
  object constructor. What is confusing from a user perspective is that the
  user specifies the externally visible constructor newBase(xInit), but internally
  we never use that and instead modify its name to e.g. newBasePatch and call that.
- Maybe instead of secretly calling a different function we could make the base
  call directly use what is really called and go for a standardized convention
  for the patching (while the external ctor could still be anything?).

  base: patch(Base, self.Base, xInit)

  That's maybe a bit too verbose, violates DRY twice, and requires the cast
  from self to Base. What about transforming `base(xInit)` into the
  corresponding `patch(Base, self.Base, xInit)` call?

  The only drawback would be that if the user goes for new-style init
  constructors, the patch signature would become:

  patch(T: typedesc[Base], self: Base, T: typedesc[Base], xInit: int)

  A bit ugly and how to avoid the variable collision?
  Corresponding base call:

  base(Base, xInit)

  => closure based approach?

  Maybe it is best to define 3 functions:
  - a named constructor as specified by the user
  - the generic `init` constructor to be future proof
  - the generic `patch` function.

  What if the user doesn't want a named constructor and is happy with just
  the `init` constructor?
  Omitting a proc name like

    constructor: proc(xInit: int)

  might be an option but it is the question whether it would be syntactically
  valid to use generics without a proc name:

    constructor: proc[T](xInit: int)  <- not valid Nim in general I guess
]#


# -----------------------------------------------------------------------------
# Via constructor closures
# -----------------------------------------------------------------------------

when true:

  type
    BasePatcher = proc(xInit: int)
    Base = ref object of RootObj
      abstract*: proc()
      templateMethod*: proc()

  proc patch(self: Base): BasePatcher =
    result = proc (xInit: int) =
      var x = xInit

      template abstract() = self.abstract()

      self.abstract = proc() =
        echo "abstract [base]"

      self.templateMethod = proc() =
        echo "template Method [base]"
        echo "x = ", x
        abstract()

  proc newBase(xInit: int): Base =
    var self = Base()
    patch(self)(xInit)
    self


  block:
    let x = newBase(10)
    x.templateMethod()


  type
    SubPatcher[T] = proc(y: T)
    Sub[T] = ref object of Base

  proc patch[T](self: Sub[T]): proc(y: T) = # SubPatcher[T] =
    result = proc(y: T) =
      # order here would be
      # - parent constructor call
      # - var base = ... instance exposure with copying original method fields
      # - variable definitions
      # - fwd decl of private procs
      # - decl of self templates
      # - decl of private procs
      # - assignment + impl of self procs
      patch(self.Base)(20)

      template abstract() = self.abstract()

      var base = Base(abstract: self.abstract, templateMethod: self.templateMethod)

      self.abstract = proc() =
        base.abstract()
        echo "abstract [sub], y = ", y

  proc newSub[T](y: T): Sub[T] =
    var self = Sub[T]()
    patch(self)(y)
    self

  block:
    let x = newSub[string]("test")
    x.templateMethod()

#[
Is there a problem here that the closure returned from patch can't be generic?
Actually I don't think so, because all generics could be specified to the
constructor generics and the patch function simply gets the same generic params.
]#