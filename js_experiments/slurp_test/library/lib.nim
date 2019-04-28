template bundleModule*(modulePath) {.dirty.} =
  static:
    const moduleCode = slurp(modulePath)
    echo moduleCode

#[
template test() =
  #static:
  #  echo "can only be called at compile time?"
  static:
    const s = "test"
  {.emit: ["var xxxx = '", s, "';"].}

#{.emit: "var xxxx = 'xxxx';".}
test()
]#