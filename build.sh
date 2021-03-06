#!/bin/bash

#file=firstSteps.nim
#file=iterate.nim
#file=repeatedIteratorUse.nim
#file=macroTest.nim
#file=parseExpr.nim
#file=threadLocalGC.nim
#file=backgroundjob.nim
#file=basicTypes.nim
#file=reprBug.nim
#file=optionals_orig.nim
#file=options.nim
#file=stringinterpolation.nim
#file=nretest.nim
#file=eknnd.nim
file=notnil.nim

fileAbs=`readlink -m $file`
traceback=false

#nim c -r -o:bin/test $file

#nim c -r -o:bin/test --parallelBuild:1 $file

nim c -r -o:bin/test --parallelBuild:1 --threads:on $file


if [ "$traceback" = true ] ; then
  echo -e "\nRunning ./koch temp c $fileAbs"
  cd ~/bin/nim-repo
  ./koch temp c `readlink -m $fileAbs`
fi

