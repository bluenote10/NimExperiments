import sugar

type
  EventHandler[T] = object
    receivers: seq[T -> void]


proc register*[T](eh: var EventHandler[T], callback: T -> void) =
  eh.receivers.add(callback)


proc send*[T](eh: EventHandler[T], msg: T) =
  for receiver in eh.receivers:
    receiver(msg)


# Example
type
  MouseClick* = object
    x, y: float

var evtMouseClick* = EventHandler[MouseClick]()


# Client A
evtMouseClick.register() do (msg: MouseClick):
  echo "A received: ", msg


# Client B
evtMouseClick.register() do (msg: MouseClick):
  echo "B received: ", msg


# Client C
evtMouseClick.send(MouseClick(x: 1, y: 2))


