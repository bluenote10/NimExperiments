

type
  Person = object
    name: string

  PersonRef1 = ref Person

  PersonRef2 = ref object
    name: string


proc greet(p: Person) =
  echo "Hello, ", p.name

let stackPerson = Person(name: "StackPerson")
greet(stackPerson)




# only either of these is allowed:
proc greet(p: ref Person) = echo "Hello, ", p.name
#proc greet(p: PersonRef1) = echo "Hello, ", p.name

# overloading on a equivalent type with different name is okay: 
proc greet(p: PersonRef2) = echo "Hello, ", p.name


#var refPerson1: PersonRef1 = ref Person(name: "refPerson1")
#var refPerson1 = PersonRef1(name: "refPerson1")
var refPerson1 = Person.new
greet(refPerson1)
refPerson1.name = "refPerson1"
greet(refPerson1)

var refPerson2 = PersonRef1(name: "refPerson2")
greet(refPerson2)

let refPerson3 = PersonRef1(name: "refPerson3 (let)")
greet(refPerson3)

refPerson1.name = "refPerson1 is mutable"
refPerson2.name = "refPerson2 is mutable"
refPerson3.name = "refPerson3 (let) is mutable as well"

greet(refPerson1)
greet(refPerson2)
greet(refPerson3)

refPerson2 = refPerson1
#refPerson3 = refPerson1 # cannot be assigned to
#refPerson1 = Per
greet(refPerson1)
greet(refPerson2)
greet(refPerson3)

echo "refPerson1: ", repr(addr(refPerson1))
echo "refPerson2: ", repr(addr(refPerson2))
#echo repr(addr(refPerson3)) # has no address

refPerson1 = Person.new # should point to something different now
echo "refPerson1: ", repr(addr(refPerson1))
echo "refPerson2: ", repr(addr(refPerson2))

refPerson1 = PersonRef1(name: "yet another person") # should point to something different now
echo "refPerson1: ", repr(addr(refPerson1))
echo "refPerson2: ", repr(addr(refPerson2))



proc printType1[T](x: T) =
  echo "Generic Repr: ", repr(x)

proc printType2[T](x: ref T) =
  echo "Generic Repr: ", repr(x)

  
printType1(stackPerson)
printType1(refPerson1)
#printType2(stackPerson) # only works for ref types
printType2(refPerson1)


proc getData(p: PersonRef1) =
  #echo p.addr
  echo "Addr of name in proc: ", repr(p.name.addr)
  p.name = "changed accidentally"

echo "Addr of refPerson1: ", repr(refPerson1.addr)
echo "Addr of refPerson1.name ", repr(refPerson1.name.addr)
getData(refPerson1)
echo "Addr of refPerson1: ", repr(refPerson1.addr)
echo "Addr of refPerson1.name ", repr(refPerson1.name.addr)
echo "Name of refPerson1 now: ", refPerson1.name



proc getData(p: Person) =
  #echo p.addr
  #echo "Addr of name in proc: ", repr(p.name.addr)
  #echo "Addr of name in proc: ", repr(addr(p.name))
  var name: string
  shallowCopy name, p.name
  echo "Addr of name in proc: ", repr(addr(name))
  

var tmpStackPerson: Person
shallowCopy tmpStackPerson, stackPerson
echo "Addr of stackPerson1: ", repr(tmpStackPerson.addr)
echo "Addr of stackPerson.name ", repr(tmpStackPerson.name.addr)
getData(stackPerson)
