import strutils, strinterp

# Output goal:
# Iteration     1    MSE:    39194.898
# Iteration     2    MSE:    26129.932
# Iteration     3    MSE:    17419.955
var mse = 58792.347
for iter in 0 ..< 10:
  mse = mse / 1.5
  echo fmt"Iteration ${iter+1}%5d    MSE: ${mse}%12.3f"
  # vs
  echo fmt"Iteration ${align($(iter+1), 5)}    MSE: ${formatFloat(mse, ffDecimal, 3).align(12)}"


# Output goal:
# README.txt                  0.002 MB
# LICENSE                     0.005 MB
# movie.mp4                  11.952 MB
let files = @[
  ("README.txt", 1925),
  ("LICENSE", 5203),
  ("movie.mp4", 12532921)
]
for file, fileSize in files.items():
  echo fmt"${file}%-20s ${filesize.float / (1 shl 20)}%12.3f MB"
  # vs
  echo fmt"""${file & repeat(" ", 20 - len(file))} ${formatFloat(filesize.float / (1 shl 20), ffDecimal, 3).align(12)} MB"""
