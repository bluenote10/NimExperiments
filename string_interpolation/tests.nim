import strutils, strinterp

when false:
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


echo high(int)
echo formatSize(high(int))

echo high(int) div 10
echo formatSize(high(int) div 10)

var x = high(int) # 23957129375
echo x
echo high(int)
when true:    echo fmt"${x.float / (1 shl 20)} MB"
when true:    echo fmt"${x.formatSize}"
when false:   echo fmt"${x}size_$"

import fenv
echo maximumPositiveValue(float)
echo maximumPositiveValue(float32)
echo maximumPositiveValue(float64)
echo formatFloat(123.456, ffScientific, precision=0)
#[
# output on Linux:   '1.234560e+02'
# output on Windows  '1.234560e+002'

  string          "${x}%-8s"    => "${x}-8s$"
  int             "${x}%5d"     => "${x}5d$"
  float           "${x}%5.2f"   => "${x}5.2f$"

  But how to escape the terminal $, i.e., if "${x}" should be followed by the string "5.2d$".

  What is "${x}size $"? Is it "<x_parsed_as_s>ize $" or "<x_parsed_as_size>"?
  What is "${x}size ${y}"? Is it "<x>size <y>" or "<x_parsed_as_size>{y}"?
  How to produce the output string "<x>size $"?

  vars with parentheses, without formatter: Still supported without mandatory terminal $
                  "${x} ${y}"        => "${x} ${y}"

  vars without parentheses, without parentheses: Still supported without mandatory terminal $
                  "$x $y"            => "$x $y"

  vars without parentheses, with formatter: Still supported?
                  "$x%.3f $y%.3f"            => "$x.3f$ $y.3f$" => would work, but $xsize_$ would fail
  to support we would have to introduce a separater, $x%size_$. Not so great.

    - what if I want to a different number of digigts for a size? 10.2 GB
    - what if I don't want to generate the size suffix, e.g., because the value occurs in a table with a header?
    - what if I want to divide by 1000 instead of 1024?

]#