# {.experimental: "notnil".}

type
  Obj = object
    run*: proc(x: string)

let obj = Obj(
  run: proc(x: string) = echo "test"
)

obj.run(1, "asdf")