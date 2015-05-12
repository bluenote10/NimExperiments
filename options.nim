#
#
#            Nim's Runtime Library
#        (c) Copyright 2015 Nim Contributors
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## :Author: Oleh Prypin

import typetraits


type
  Option*[T] = object
    ## An optional type that stores its value and state separately in a boolean.
    val: T
    isSome: bool


proc some*[T](val: T): Option[T] =
  ## Returns a ``Option`` that has this value.
  result.isSome = true
  result.val = val

proc none*(T: typedesc): Option[T] =
  ## Returns a ``Option`` for this type that has no value.
  result.isSome = false


converter toBool*(o: Option): bool =
  ## Same as ``isSome``. Allows to use a ``Option`` in boolean context.
  o.isSome

proc isNone*(o: Option): bool =
  ## Returns ``true`` if `o` is `none`.
  not o.isSome

proc isSome*(o: Option): bool =
  ## Returns ``true`` if `o` isn't `none`.
  o.isSome

template `?=`*(into: expr, o: Option): bool {.immediate.} =
  ## Returns ``true`` if `o` isn't `none`.
  ##
  ## Injects a variable with the name specified by the argument `into`
  ## with the value of `o`, or its type's default value if it is `none`.
  ##
  ## .. code-block:: nim
  ##
  ##   proc message(): ?string =
  ##     some "Hello"
  ##
  ##   if m ?= message():
  ##     echo m
  var into {.inject.}: type(o.val)
  if o:
    into = o.val
  o


proc get*[T](o: Option[T]): T =
  ## Returns the value of `o`. Raises ``FieldError`` if it is `none`.
  if not o:
    raise newException(FieldError, "Can't obtain a value from a `none`")
  o.val

proc unsafeGet*[T](o: Option[T]): T =
  ## Returns the value of a `some`. Behavior is undefined for `none`.
  assert o.isSome, "none has no val"
  o.val



template getOrElse*[T](o: Option[T], default: T): T =
  ## Returns the value of `o`, or `default` if it is `none`.
  if o: o.val
  else: default

template getOr*[T](a, b: Option[T]): Option[T] =
  ## Returns `a` if it is `some`, otherwise `b`.
  if a: a
  else: b

proc map*[A,B](o: Option[A], f: proc (x: A): B): Option[B] =
  ## Takes an modification proc f, and applies it to the optional value, i.e.,
  ## returns `some(f(o.val))` if `o` is has a value otherwise `none`
  if x ?= o:
    some(f(x))
  else:
    none(B)

proc flatMap*[A,B](o: Option[A], f: proc (x: A): Option[B]): Option[B] =
  ## Takes an modification proc f with an optional result, and applies it to
  ## the optional value. This means if `o` has a value, the result becomes
  ## the optional result of the computation `f(o.val)`. If `o` is `none`,
  ## the result is `none(B)`.
  if x ?= o:
    f(x)
  else:
    none(B)

iterator items*[T](o: Option[T]): T =
  if x ?= o:
    yield x

proc `==`*(a, b: Option): bool =
  ## Returns ``true`` if both ``Option`` are `none`,
  ## or if they have equal values
  (a.isSome and b.isSome and a.val == b.val) or (not a.isSome and not b.isSome)

proc `$`[T](o: Option[T]): string =
  ## Converts to string: `"some(value)"` or `"none(type)"`
  if o.isSome:
    "some(" & $o.val & ")"
  else:
    "none(" & T.name & ")"


when isMainModule:
  template expect(E: expr, body: stmt) =
    try:
      body
      assert false, E.type.name & " not raised"
    except E:
      discard


  block: # example
    proc find(haystack: string, needle: char): Option[int] =
      for i, c in haystack:
        if c == needle:
          return some i

    assert("abc".find('c').get == 2)

    let result = "team".find('i')

    assert result == none(int)
    assert result.isSome == false

    if pos ?= "nim".find('i'):
      assert pos is int
      assert pos == 1
    else:
      assert false

    assert(("team".find('i').getOrElse(-1)) == -1)
    assert(("nim".find('i').getOrElse(-1)) == 1)

  block: # some
    assert some(6).get == 6
    assert some("a").unsafeGet == "a"
    assert some(6).isSome
    assert some("a")

  block: # none
    expect FieldError:
      discard none(int).get
    assert(not none(int).isSome)
    assert(not none(string))

  block: # equality
    assert some("a") == some("a")
    assert some(7) != some(6)
    assert some("a") != none(string)
    assert none(int) == none(int)

    when compiles(some("a") == some(5)):
      assert false
    when compiles(none(string) == none(int)):
      assert false

  block: # stringification
    assert "some(7)" == $some(7)
    assert "none(int)" == $none(int)

  block: # or
    assert some(1).getOr(some(2)) == some(1)
    assert none(string).getOr(some("a")) == some("a")
    assert none(int).getOr(none(int)) == none(int)
    assert some(5).getOrElse(2) == 5
    assert none(string).getOrElse("a") == "a"

    when compiles(some(1).getOrElse("2")):
      assert false
    when compiles(none(int).getOr(some("a"))):
      assert false

  block: # extraction template
    if a ?= some(5):
      assert a == 5
    else:
      assert false

    if a ?= none(string):
      assert false

  block: # map
    let a = some(1)
    let b = a.map(proc (x: int): string = $x)
    assert(b.isSome and b.get == "1")
    let c = none(int)
    assert(c.map(proc (x: int): string = $x).isNone)
    
  block: # flatMap vs map
    proc lookupName(i: int): Option[string] =
      case i:
      of 1: some("Bob")
      of 2: some("Alice")
      else: none(string)
    proc lookupHome(s: string): Option[string] =
      case s:
      of "Bob": some("house")
      else: none(string)
    assert(some(1).flatMap(lookupName).map(lookupHome) == some(some("house")))
    assert(some(2).flatMap(lookupName).map(lookupHome) == some(none(string)))
    assert(some(1).flatMap(lookupName).flatMap(lookupHome) == some("house"))
    assert(some(2).flatMap(lookupName).flatMap(lookupHome) == none(string))

  block: # iterator
    let a = some(1)
    var yields: seq[int] = @[]
    for x in a:
      yields.add(x)
    assert(yields == @[1])
    for x in none(int):
      yields.add(x)
    for x in some(42):
      yields.add(x)
    assert(yields == @[1, 42])
    
