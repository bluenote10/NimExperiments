
import os, threadpool

type
  Buffer = object
    data: seq[int]

  BufferOnHeap = Buffer


var globalBuffer = BufferOnHeap.new


proc fillThread(buffer: var BufferOnHeap) {.thread.} =
  for i in 0 .. 10:
    buffer.data.add(0)
    os.sleep(10)
    
proc clearThread(buffer: var BufferOnHeap) {.thread.} =
  for i in 0 .. 10:
    if buffer.data.len > 0:
      buffer.data.delete(0)
    os.sleep(10)


var thread1: TThread[BufferOnHeap]
var thread2: TThread[BufferOnHeap]    
createThread(thread1, fillThread, globalBuffer)
createThread(thread2, clearThread, globalBuffer)
    


    
