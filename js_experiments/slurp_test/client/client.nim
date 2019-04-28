import ../library/lib

#import os
#static:
#  echo os.getAppDir

const modulePath = "jsmoduleA.js"

static:
  const moduleCode = slurp(modulePath)
  echo moduleCode

bundleModule(modulePath)
