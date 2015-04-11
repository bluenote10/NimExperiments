import opengl # Leave this line out and the crash disappears
import threadpool, os

proc do_work(i: int) {.thread.} =
  sleep(100)
  echo "job done"

var thread: TThread[int]

createThread(thread, do_work, 0) # Leave this line out and the crash disappears
os.sleep(1000) # Leave this line out and the crash disappears
echo "all done"
