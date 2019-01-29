proc takesFunc(f: proc (x: int) {.gcsafe, locks: 0.}) =
  echo "takes single Func"

proc takesFuncs(fs: openarray[proc (x: int) {.gcsafe, locks: 0.}]) =
  echo "takes multiple Func"

takesFunc(proc (x: int) {.gcsafe, locks: 0.} = echo x)
takesFuncs([proc (x: int) {.gcsafe, locks: 0.} = echo x])

#takesFuncs([(proc (x: int) {.gcsafe, locks: 0.})(proc (x: int) {.gcsafe, locks: 0.} = echo x)])

#[

type
  Func = proc (x: int) {.gcsafe, locks: 0.}

proc takesFunc(f: Func) =
  echo "takes single Func"

proc takesFuncs(fs: openarray[Func]) =
  echo "takes multiple Func"

let testFunc1: Func = (proc (x: int) {.gcsafe, locks: 0.} = echo x)

takesFunc(testFunc1)
takesFuncs([testFunc1])

proc testFunc2(x: int) {.gcsafe, locks: 0.} =
  echo x

takesFunc(testFunc2)
#takesFuncs([testFunc2])
takesFuncs([(proc (x: int) {.gcsafe, locks: 0.})(testFunc2)])

]#









#[
#import jsffi

type
  Func = proc (x: int) {.gcsafe, locks: 0.}


proc nested() =
  let testFunc1: Func = (proc (x: int) {.gcsafe, locks: 0.} = echo x)
  testFunc1(0)

  proc testFunc2(x: int) {.gcsafe, locks: 0.} =
    echo x
  testFunc2(0)

  let t: Func = testFunc2

  proc a(f: Func) =
    echo "a"

  a(testFunc2)

  proc b(fs: seq[Func]) =
    echo "b"

  b(@[testFunc2.Func])

#[
proc f(arg: seq[proc (x: int) {.gcsafe, locks: 0.}]) =
  echo arg.len

f(@[proc (x: int) {.gcsafe, locks: 0.} = echo x])
]#

nested()
]#