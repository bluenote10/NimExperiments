import math
import sequtils
import algorithm
import macros

macro debug*(n: varargs[expr]): stmt =
  # `n` is a Nim AST that contains the whole macro invocation
  # this macro returns a list of statements:
  result = newNimNode(nnkStmtList, n)
  # iterate over any argument that is passed to this macro:
  for i in 0..n.len-1:
    # add a call to the statement list that writes the expression;
    # `toStrLit` converts an AST to its string representation:
    add(result, newCall("write", newIdentNode("stdout"), toStrLit(n[i])))
    # add a call to the statement list that writes ": "
    add(result, newCall("write", newIdentNode("stdout"), newStrLitNode(": ")))
    # add a call to the statement list that writes the expressions value:
    #add(result, newCall("writeln", newIdentNode("stdout"), n[i]))
    add(result, newCall("write", newIdentNode("stdout"), n[i]))
    # separate by ", "
    if i != n.len-1:
      add(result, newCall("write", newIdentNode("stdout"), newStrLitNode(", ")))

  # add new line
  add(result, newCall("writeln", newIdentNode("stdout"), newStrLitNode("")))



type
  Row = seq[float]
  Data = seq[Row]


proc dist(v: Row): float =
  var sum = 0.0
  for i,x in v:
    sum += x*x
  return sqrt(sum)

proc randomSign(): float =
  if random(2) == 0: 1.0 else: -1.0

iterator gen(n, d: int, r: float): Row =
  var i = 0
  while i < n:
    var vec = newSeq[float](d)
    for j,x in vec:
      vec[j] = random(r) * randomSign()
    if dist(vec) < r:
      yield vec
      inc i
      

proc randomSample(n, d: int, r: float): Data =
  result = newSeqWith(n, newSeq[float](d))
  var i = 0
  for row in gen(n,d,r):
    result[i] = row
    inc i

proc getKDist(data: Data, k: int): float =
  var dists = data.mapIt(float, dist(it))
  #for d in dists: echo d
  sort(dists, system.cmp)
  #echo "sorted:"
  #for d in dists: echo d
  #echo "median: ", dists[data.len div 2]
  return dists[k-1]

#for r in randomSample(50, 5, 10.0):
#  echo r
#echo getKDist(randomSample(100, 1, 1.0), 5)

proc expTheo(k, n, d: int, r: float): float =
  pow(k.float/(n+1).float, 1.0/d.float) * r

proc expMoCa(k, n, d: int, r: float): float =
  let iterations = 10_000
  var sum = 0.0
  for iter in 1 .. iterations:
    let sample = randomSample(n, d, r)
    let kDist = getKDist(sample, k)
    sum += kDist
  return sum / iterations.float
    
randomize()
let tests = [
  (1, 1, 1, 1.0),
  (5, 1, 1, 1.0),
  (5, 5, 1, 1.0),
  (1, 1, 1, 10.0),
  (5, 3, 3, 10.0),
  (1, 1, 10, 1.0),
  (100, 50, 2, 1.0),
]

for test in tests:
  let (n,k,d,r) = test
  echo "\n"
  debug n,k,d,r
  debug expTheo(k, n, d, r)
  debug expMoCa(k, n, d, r)

