
proc require*(lib: cstring, T: typedesc): T {.importcpp: """require(#)""".}
proc requireWithCall*(lib: cstring, T: typedesc): T {.importcpp: """require(#)()""".}

proc debug*[T](x: T) {.importc: "console.log", varargs.}

proc isNil[T](a: openarray[T]): bool {.importcpp: "(# === null)"}

proc joinImpl*(a: openArray[cstring]; sep: cstring = ""): cstring {.importcpp: "#.join(#)".}

proc join*(a: openArray[cstring]; sep: cstring = ""): cstring =
  if a.isNil:
    "".cstring
  else:
    joinImpl(a, sep)

# -----------------------------------------------------------------------------
# JDict
# -----------------------------------------------------------------------------

type
  JDict*[K, V] = ref object

proc `[]`*[K, V](d: JDict[K, V], k: K): V {.importcpp: "#[#]".}
proc `[]=`*[K, V](d: JDict[K, V], k: K, v: V) {.importcpp: "#[#] = #".}

proc newJDict*[K, V](): JDict[K, V] {.importcpp: "{@}".}

proc contains*[K, V](d: JDict[K, V], k: K): bool {.importcpp: "#.hasOwnProperty(#)".}

proc del*[K, V](d: JDict[K, V], k: K) {.importcpp: "delete #[#]".}

iterator items*[K, V](d: JDict[K, V]): K =
  var kkk: K
  {.emit: ["for (", kkk, " in ", d, ") {"].}
  yield kkk
  {.emit: ["}"].}

iterator pairs*[K, V](d: JDict[K, V]): (K, V) =
  var kkk: K
  var vvv: V
  {.emit: "for (", kkk, " in ", d, ") {".}
  {.emit: [vvv, " = ", d[kkk]].}
  yield (kkk, vvv)
  {.emit: "}".}

proc keys*[K, V](d: JDict[K, V]): seq[K] {.importcpp: "Object.keys(#)".}

proc values*[K, V](d: JDict[K, V]): seq[V] {.importcpp: "Object.values(#)".}

proc items*[K, V](d: JDict[K, V]): seq[(K, V)] =
  result = newSeq[(K, V)]()
  for k in d:
    result.add((k, d[k]))

#[
proc values*[K, V](d: JDict[K, V]): seq[V] =
  # TODO: This could be optimized
  result = newSeq[V]()
  for k, v in d.pairs:
    result.add(v)
]#

# TODO: How to solve this?
# proc `toJSStr`*[K, V](d: JDict[K, V]): cstring = cstring"asdf"
# proc `$`*[K, V](d: JDict[K, V]): cstring = toJSStr(d)

# -----------------------------------------------------------------------------
# JSeq
# -----------------------------------------------------------------------------

type
  JSeq*[T] = ref object

proc `[]`*[T](s: JSeq[T], i: int): T {.importcpp: "#[#]", noSideEffect.}
proc `[]=`*[T](s: JSeq[T], i: int, v: T) {.importcpp: "#[#] = #", noSideEffect.}

proc newJSeq*[T](len: int = 0): JSeq[T] {.importcpp: "new Array(#)".}
proc len*[T](s: JSeq[T]): int {.importcpp: "#.length", noSideEffect.}
proc add*[T](s: JSeq[T]; x: T) {.importcpp: "#.push(#)", noSideEffect.}

proc shrink*[T](s: JSeq[T]; shorterLen: int) {.importcpp: "#.length = #", noSideEffect.}

# -----------------------------------------------------------------------------
# seq JS extensions (use with care, violate seq semantics)
# -----------------------------------------------------------------------------

proc sortJS*[T](s: seq[T]): seq[T] {.importcpp: "#.sort()".}
proc sortJS*[T](s: seq[T], compare: proc(a: T, b: T): int): seq[T] {.importcpp: "#.sort(#)".}

