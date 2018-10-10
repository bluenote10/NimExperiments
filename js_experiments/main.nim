import kdom

let rootElem = getElementById("ROOT")

proc tdiv(text: cstring): Element =
  let elem = document.createElement("div")
  let elemText = document.createTextNode(text)
  elem.appendChild(elemText)
  elem

rootElem.appendChild(tdiv("test"))