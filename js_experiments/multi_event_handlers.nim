import dom
import js_utils


#type
#  CallbackBase = ref object of RootObj

type
  ClickCallback* = proc ()
  InputCallback* = proc(s: cstring)

type
  EventHandlerBase = ref object of RootObj

  OnClick = ref object of EventHandlerBase
    dispatch: ClickCallback
  OnInput = ref object of EventHandlerBase
    dispatch: InputCallback


type
  EventHandler* = proc(ev: Event)

  UiUnit* = ref object of RootObj
    eventHandlers: seq[EventHandlerBase]
    nativeHandlers: JDict[cstring, EventHandler]


method getDomNode*(self: UiUnit): Node {.base.} =
  doAssert false, "called abstract method 'getDomNode'"

method activate(self: UiUnit) =
  for eventHandler in self.eventHandlers:
    #case eventHandler
    #of OnClick:
    #  eventHandler.dispatch()
    if eventHandler of OnClick:

      proc onClick(e: Event) =
        eventHandler.OnClick.dispatch()
      self.getDomNode().addEventListener("click", onClick)
      self.nativeHandlers["click"] = onClick


    elif eventHandler of OnInput:
      eventHandler.OnInput.dispatch("asfd")

      proc onInput(e: Event) =
        eventHandler.OnInput.dispatch(e.target.value)
      self.getDomNode().addEventListener("input", onInput)
      self.nativeHandlers["input"] = onInput

# Should these be methods so that derived classes could overload
# the behavior? Or even proc fields?

# Should they be defined on UiUnit or on UiUnitDom if we introduce
# a subclass?

# How to make sure we only attach an onClick once? Or should
# there be multiple handlers of one type? The current implementation
# of activate would only bind the last added handler.
# - use a dict after all with some kind of identifier?
# - filter unique here on insert?
# - collect all of same type within activate and call them all?
proc onClick*(unit: UiUnit, cb: ClickCallback) =
  unit.eventHandlers.add(OnClick(dispatch: cb))

proc onInput*(unit: UiUnit, cb: InputCallback) =
  unit.eventHandlers.add(OnInput(dispatch: cb))


type

  Button* = ref object of UiUnit
    el: Element

  Input* = ref object of UiUnit
    el: Element


proc button(): Button =
  Button(eventHandlers: @[], el: Element())

method getDomNode*(self: Button): Node =
  self.el

proc input(): Input =
  Input(eventHandlers: @[], el: Element())

method getDomNode*(self: Input): Node =
  self.el

let btn = button()
let inp = input()

btn.onClick() do ():
  echo "on click"

inp.onInput() do (s: cstring):
  echo "on input"

btn.activate()
inp.activate()