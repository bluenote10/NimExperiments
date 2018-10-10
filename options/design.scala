// https://scastie.scala-lang.org/

case class DB(handle: Int)
case class User(name: String)
case class Address(street: String)

def fetchUser(db: DB): Option[User] = Some(User("John"))
def fetchAddress(user: User): Option[Address] = Some(Address("SomeStreet"))

def lookupStreet(db: Option[DB]) =
  db.flatMap(db => fetchUser(db))
    .flatMap(user => fetchAddress(user))
    .map(_.street)

val db = Some(DB(0))
print(lookupStreet(db))

def lookupStreetFor(db: Option[DB]) =
  for (
    db <- db;
    user <- fetchUser(db);
    address <- fetchAddress(user)
  ) yield
		address.street

print(lookupStreetFor(db))


// example with list requires monadic conversion
def fetchUser(db: DB): List[User] = List(User("John"), User("Jane"))
def fetchAddress(user: User): Option[Address] = Some(Address("SomeStreet"))

def lookupStreet(db: Option[DB]) =
  db.toList
    .flatMap(db => fetchUser(db))
    .flatMap(user => fetchAddress(user))
    .map(_.street)

val db = Some(DB(0))
print(lookupStreet(db))


// extension to Either
case class DB(handle: Int)
case class User(name: String)
case class Address(street: String)
case class Error(msg: String)

def fetchUser(db: DB): Either[Error, User] = Left(Error("failed to fetch user. Fuzzy matches: ..."))
def fetchAddress(user: User): Either[Error, Address] = Right(Address("SomeStreet"))

def lookupStreet(db: Either[Error, DB]) =
  db.flatMap(db => fetchUser(db))
    .flatMap(user => fetchAddress(user))
    .map(_.street)

val db = Right(DB(0))
print(lookupStreet(db))
