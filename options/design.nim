
when false:
  import options
  import tables
  import future

  type
    DB = object
    User = object
      name: string
      address: Option[Address]
    Address = object
      street: string

  #[

  proc fetchUser(db: DB): Option[User] = some(User(name: "", address: none(Address)))
  proc fetchAddress(user: User): Option[Address] = user.address

  proc lookupStreet(db: Option[DB]): Option[string] =
    #[
    db.flatMap(db => db.fetchUser())
      .flatMap(user => user.fetchAddress())
      .map(address => address.street)
    ]#
    db.flatMap(proc (db: DB): Option[User] = db.fetchUser())
      .flatMap(proc (user: User): Option[Address] = user.fetchAddress())
      .map(address => address.street)

  ]#


when false:
  proc lookupStreet(t: Table[int, User], id: int): Option[string] =
    #let user = t.get(id)
    #let address = t.get(id).flatMap(user => user.address)
    #let address = t.get(id).flatMap(proc (user: User): Option[Address] = user.address)
    #echo user
    for user in t.get(id):
      for address in user.address:
        result = some(address.street)


import options
import tables
import future

type
  User = object
    name: string
    address: Option[Address]
  Address = object
    street: string

proc get[A, B](t: Table[A, B], key: A): Option[B] =
  try:
    some(t[key])
  except KeyError:
    none(B)

proc `$`[T](o: Option[T]): string =
  #o.map(x => "Option(" & $x & ")").getOrDefault("none")
  o.map(proc (x: T): string = "Option(" & $x & ")").get("none")

iterator items[T](o: Option[T]): T =
  if o.isSome:
    yield o.get


proc lookupStreet(t: Table[int, User], id: int): Option[string] =
  for user in t.get(id):
    for address in user.address:
      result = some(address.street)

proc lookupStreetExceptions(t: Table[int, User], id: int): Option[string] =
  try:
    let user = t[0]
    return user.address.map(address => address.street)
  except ValueError:
    return none(string)

var t = initTable[int, User]()
t[0] = User(name: "John", address: some(Address(street: "SomeStreet")))

echo lookupStreet(t, 0)
echo lookupStreetExceptions(t, 0)


#[
Problem with
type
  A = object
    optInt: Option[int]
  Outer = object
    optTable: Option[Table[int, A]]

outer.optTable??.get(key).optInt?
get(outer.optTable??, key).optInt?
get((outer.optTable?)?, key).optInt?

two issues:
- most likely it will again break method call syntax, breaking the function chaining flow...
- two questionmarks required, one for marking the outer.optTable lookup, and another for marking it as a trigger to the `get` call.

vs.

for table in outer.optTable:
  for a in table.get(key):
    for i in a.optInt:
      yield i
]#
