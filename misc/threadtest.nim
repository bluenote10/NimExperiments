# This is a comment

#import threadpool, os

import os
import threadpool
#import opengl
#import src/option


when false:
  const concurrent = 1

  type StringChannel = TChannel[string]
  type Arg           = ptr StringChannel
  type Worker        = TThread[Arg]

  #var channels:array [concurrent, StringChannel]
  #var threads:array  [concurrent, Worker]

  proc do_work(channel: Arg) {.thread.} =
    channel[].open()
    echo "Worker started"
    var c = 0
    for iter in 0..5:
      channel[].send("count = " & $c)
      inc c
      os.sleep(100)
    echo "Terminating Worker"


  proc exported*() =
    var channel: StringChannel
    var thread: TThread[ptr StringChannel]
      #Worker

    createThread(thread, do_work, addr(channel))

    while true:
      os.sleep(10)
      echo channel.recv()

  when isMainModule:
    exported()



when true:

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

  shaderProgramCreate("", "")
