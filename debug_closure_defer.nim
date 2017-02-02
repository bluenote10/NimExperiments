
when false:
    proc lineIter*(filename: string): iterator(): string =
      result = iterator(): string {.closure.} =
        for line in lines(filename):
          yield line

    var count = 0
    let iter = lineIter("/tmp/test_file")
    for line in iter():
      count += 1

else:
    iterator lineIterOrig*(filename: string): string {.closure.} =
      var f = open(filename, bufSize=8000)
      defer:
        echo "defer called"
        close(f)   # <-- commenting defer "solves" the problem
      var res = TaintedString(newStringOfCap(80))
      while f.readLine(res): yield res

    iterator lineIter*(filename: string): string {.closure.} =
      var f = open(filename, bufSize=8000)
      try:
        var res = TaintedString(newStringOfCap(80))
        while f.readLine(res):
          yield res
      finally:
        echo "close called"
        close(f)

    var count = 0
    for line in lineIter("/tmp/test_file"):
      count += 1
    echo count

