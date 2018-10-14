import ncurses
import os
import sequtils
import sugar
import strformat

type
  WindowPtr = ptr window

  File = tuple[kind: PathComponent, path: string]

proc getFiles(): seq[File] =
  toSeq(walkDir("."))
  

proc initWindow(): WindowPtr =
  var win = initscr()
  noecho()
  curs_set(0)
  start_color()
  use_default_colors()
 
  win.keypad(true) # get function keys
  return win

proc drawFiles(window: WindowPtr, files: seq[File]) =
  window.wmove(0, 0)
  for file in files:
    window.waddstr(file.path & "\n")
  window.wrefresh()

proc drawTestWrap(window: WindowPtr) =
  window.wmove(0, 0)
  for i in 1 .. 100:
    for j in 1 .. 100:
      window.waddstr(&" ({i} {j})")
    window.waddstr("\n")
  window.wrefresh()

proc drawTestColor(window: WindowPtr) =
  window.wmove(0, 0)
  init_color(COLOR_RED, 0, 1000.cshort, 0)
  discard init_pair(1, COLOR_RED, COLOR_BLACK)
  for i in 1 .. 10:
    # discard init_pair(i.cshort, (i mod 7).cshort, (1 + i mod 7).cshort)
    #init_color(COLOR_RED, (i*10).cshort, 0, 0)
    window.wattron(COLOR_PAIR(1))
    window.waddstr(&" {i} ")
    window.wattroff(COLOR_PAIR(1))
    window.wrefresh()

proc main() =
  var window = initWindow()
  let files = getFiles()
  
  drawFiles(window, files)
  drawTestColor(window)

  let ch = window.wgetch()
  endwin()
  echo "Exit char: ", ch

main()
#addstr("hello world")
#discard refresh()
#discard getch()
