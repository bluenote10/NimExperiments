#!/bin/bash

# Notes:
# * `--noMain`` seems to have no effect, probably required for `--app:lib`
# * adding `--debugger:native` allows to run `readelf -wi libnimlib.so | less` (or objdump -g) to see information
#   on the parameters of the exported functions. This is not possible in general with just nm/objdump.
#   see: https://unix.stackexchange.com/questions/104468/finding-function-parameters-for-functions-in-shared-object-libraries
echo -e "\n *** compiling nimlib"
nim c --header --app:lib --noMain nimlib.nim
cp nimcache/nimlib.h .

echo -e "\n *** Output of ldd"
ldd libnimlib.so
echo -e "\n *** Output of nm"
nm -D libnimlib.so | grep --color -E 'nimfunc|$'
echo -e "\n *** Output of objectdump"
objdump -T libnimlib.so | grep --color -E 'nimfunc|$'

echo -e "\n *** compiling C client"
gcc c_client.c -o c_client -I${HOME}/bin/nim-repo/lib -L. -lnimlib -Wall
ldd c_client

echo -e "\n *** running C client"
./c_client