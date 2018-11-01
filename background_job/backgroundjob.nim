
import utils
import os
import threadpool


type
  ReloadChannel = TChannel[string]

proc backgroundThread() =
  for i in 0..5:
    os.sleep(100)
    echo "Sleeping ", i

proc backgroundPoller(channel: ptr ReloadChannel) {.thread.} =
  #echo channel[].recv()
  channel[].open()
  echo "Channel opened"
  for i in 0..5:
    os.sleep(100)
    echo "Trying to send"
    channel[].send("Sleeping " & $i)
    echo "Send"
  #channel[].close()
  echo "Terminating thread"

type
  ShaderProgram = object
    numUnifs: int
    numAttrs: int

proc shaderProgramCreate*(vsFile, fsFile: string) =
  echo "Spawning background thread"
  #spawn backgroundThread()
  #sync()

  var thread: TThread[ptr ReloadChannel]
  var channel: ReloadChannel

  createThread(thread, backgroundPoller, addr(channel))

  echo "Spawning background thread [done]"
  echo "Thread: ", thread.repr
  echo "Channel: ", channel.repr
  #joinThread(thread)

  while true:
    echo "Trying to receive:"
    #echo "Received: ", channel.tryRecv().repr
    os.sleep(100)

  echo "Closing channel"
  #channel.close()
  #sleep(5000)



proc spawnBackgroundThread[T](f: proc (): T) =

  var thread: TThread[ptr TChannel[T]]
  var channel: TChannel[T]

  createThread(thread, f, addr(channel))
  discard



runUnitTests:

  proc f(): int {.gcsafe.} =
    42

  spawnBackgroundThread(f)
