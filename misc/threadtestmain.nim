#import threadtest

#shaderProgramCreate("", "")


import opengl
import threadpool, os

proc do_work(i: int) {.thread.} =
  sleep(100)
  echo "job done"
  
var thread: TThread[int]

createThread(thread, do_work, 0)
os.sleep(1000)
echo "all done"
