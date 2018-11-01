import os, threadpool

import sequtils

proc someproc(a, b: string): seq[tuple[a, b: char]] =
    let
        s1 = toSeq(a)
        s2 = toSeq(b)
    result = zip(s1, s2)


echo someproc("asdf", "kjgs")
    
when false:
  proc spawnBackgroundJob[T](f: iterator (): T): TChannel[T] =

    type Args = tuple[iter: iterator (): T, channel: ptr TChannel[T]]

    proc threadFunc(args: Args) {.thread.} =
      echo "Thread is starting"
      let iter = args.iter
      var channel = args.channel[]

      for i in iter():
        echo "Sending ", i
        channel.send(i)

    var thread: TThread[Args]
    var channel: TChannel[T]
    channel.open()

    let args = (f, channel.addr)
    createThread(thread, threadFunc, args)

    result = channel


  iterator test(): int {.closure.} =
    sleep(500)
    yield 1
    sleep(500)
    yield 2

  var channel = spawnBackgroundJob[int](test)

  for i in 0 .. 10:
    sleep(200)
    echo channel.peek()

  echo "Finished"


