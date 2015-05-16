import nre
import macros

macro test(): stmt =
  let match = "hello".match(re"h")
  result = newStmtList()

test()

template test2(): stmt {.immediate.} =
  let match = "hello".match(re"h")
  echo "test"

test2()

