import colors, terminal
const Nim = "Efficient and expressive programming."
var
  fg = colYellow
  bg = colBlue
  int = 1.0

enableTrueColors()
#for i in 1..15:
#    styledEcho bgPrefix, bg, fgPrefix, fg, Nim, resetStyle
#    int -= 0.01
#    fg = intensity(fg, int)

setForegroundColor colRed
setBackgroundColor colGreen
styledEcho "Red on Green.", resetStyle