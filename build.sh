#!/bin/bash

file=iterate.nim
#file=repeatedIteratorUse.nim

fileAbs=`readlink -m $file`
traceback=false

#nim c -r -o:bin/test $file

nim c -r -o:bin/test --parallelBuild:1 $file

if [ "$traceback" = true ] ; then
  echo -e "\nRunning ./koch temp c $fileAbs"
  cd ~/bin/nim-repo
  ./koch temp c `readlink -m $fileAbs`
fi

