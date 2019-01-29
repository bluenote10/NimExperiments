#[
type
  Func = proc (x: int)

proc makeFuncProc(f: Func): Func =
  Func(f)

template makeFuncTemplate(f: Func): Func =
  Func(f)

proc test(arg: openarray[Func]) =
  echo arg.len

test([makeFuncProc(proc (x: int) = echo x)])
test([makeFuncTemplate(proc (x: int) = echo x)])
]#


#[
type
  Func = proc (x: int)

proc makeTupleProc(f: Func): (string, Func) =
  ("x", Func(f))

template makeTupleTemplate(f: Func): (string, Func) =
  ("x", Func(f))

proc test(arg: openarray[(string, Func)]) =
  echo arg.len

test([makeTupleProc(proc (x: int) = echo x)])
test([makeTupleTemplate(proc (x: int) = echo x)])
]#

#[
# variant with illformed ast
import sugar

type
  Func = proc (x: int)

proc makeFuncProc(f: Func): Func =
  Func(f)

template makeFuncTemplate(f: Func): Func =
  Func(f)

proc test(arg: openarray[Func]) =
  echo arg.len

test([makeFuncProc((x: int) => echo x)])     # works
test([makeFuncTemplate((x: int) => echo x)]) # error
]#

import sugar

type
  Func = proc (x: int): int

proc makeFuncProc(f: Func): Func =
  let f2: Func = f
  f2

template makeFuncTemplate(): Func =
  let f2: Func = proc(x: int) = x+1
  f2

proc test(arg: openarray[Func]) =
  echo arg.len

test([makeFuncProc((x: int) => x+1)])     # works
test([makeFuncTemplate()]) # error
