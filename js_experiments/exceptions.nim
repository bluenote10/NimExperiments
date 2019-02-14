proc debug*[T](x: T) {.importc: "console.log", varargs.}

proc test1() =
  {.emit: """
  throw "This throws a native exception";
  """.}

proc test2() =
  {.emit: """
  require("asdf");
  """.}

try:
  debug("calling test".cstring)
  test2()
except:
  debug("caught exception".cstring)
  let e = getCurrentException()
  debug(e)
  echo "msg: ", getCurrentExceptionMsg()
  {.emit: "console.log(lastJSError);".}



