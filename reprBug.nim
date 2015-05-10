
discard """
type 
  RenderAPIType* {.size: sizeof(cint).} = enum 
    RenderAPI_None,
    RenderAPI_OpenGL,

type 
  TextureHeader* = object 
    API* : RenderAPIType
    TextureSize* : Sizei

type 
  Texture*  = object 
    Header* : TextureHeader

var t: Texture

echo "\n *** set enum:"
t.Header.API = RenderAPI_OpenGL
echo repr(t)
echo repr(t.Header.API)

echo "\n *** set something else:"
t.Header.TextureSize = Sizei(w: 1, h: 1)
echo repr(t)
echo repr(t.Header.API)
"""

type
  SomeEnum {.size: sizeof(cint).} = enum a, b
  
  StructLike* = object 
    e* : SomeEnum
    f* : cint

var x: StructLike 

x.e = b
echo "Enum: ", x.e
echo "Repr: ", repr(x)


x.f = 42
echo "Enum: ", x.e
echo "Repr: ", repr(x)
