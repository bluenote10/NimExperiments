import ../library/lib2

#[
const modules = [
  slurp("jsmoduleA.js")
]
bundleModules(modules)
]#

#static:
#  bundleModule()

#static:
#  echo test()

#{.emit: slurp("jsmoduleA.js").}

bundleModules([
  "jsmoduleA.js",
  "jsmoduleB.js",
])
