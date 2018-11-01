echo "Test"

type 
  Generic = ref object of RootObj
  Coin = Generic
  Pen  = Generic

let 
  yes : seq[Generic] = @[Coin(), Coin(), Coin()]  #Compiles
  no  : seq[Generic] = @[Coin(), Pen(), Coin()]   #Does not compile

echo "Test", repr(yes), repr(no)
