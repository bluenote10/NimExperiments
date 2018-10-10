#[
type
  MyKind = enum
    Kind1, Kind2, Kind3

  MyType = ref object
    case kind: MyKind
    of Kind1:
      someAttribute: string
    of Kind2:
      someAttribute: string
    of Kind3:
      someOtherAttribute: int
]#

#import strutils

let s = "asdf"
if "a" in s:
  echo "yes"