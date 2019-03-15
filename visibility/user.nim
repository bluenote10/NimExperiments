import lib

type
  ElementA = ref object of Element
    a: int
  ElementB = ref object of Element
    b: int

proc newElementA(): ElementA =
  newElement("A", ElementA(a: 1))
  #newElement(ElementA, id="A", a=1)

proc newElementB(): ElementB =
  newElement("B", ElementB(b: 2))
  #newElement(ElementB, id="A", b=2)

let elements = @[
  newElementA().Element,
  newElementB(),
]

run(elements)