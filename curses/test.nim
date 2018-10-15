import ncurses
import os
import strutils
import sequtils
import sugar
import strformat
import algorithm

type
  WindowPtr = ptr window

  File = tuple[kind: PathComponent, path: string]

  FileList = object
    absPath: string
    files: seq[File]
    highlighted: int
    scrollOffset: int


proc cmpFile(a: File, b: File): int =
  template tryReturn() =
    if result != 0:
      return result
  let aKindSimple = a.kind == pcFile or a.kind == pcLinkToFile
  let bKindSimple = b.kind == pcFile or b.kind == pcLinkToFile
  result = cmp(aKindSimple, bKindSimple)
  tryReturn()
  result = cmp(a.path.startsWith('.'), b.path.startsWith('.'))
  tryReturn()
  result = cmp(a.path.toLowerAscii, b.path.toLowerAscii)

proc getFileList(directory=getCurrentDir()): FileList =
  let files = toSeq(walkDir(directory)).sorted(cmpFile)
  FileList(
    absPath: absolutePath(directory),
    files: files,
    highlighted: 0,
    scrollOffset: 0,
  )

proc decHighlighted(fl: var FileList) =
  if fl.highlighted > 0:
    fl.highlighted -= 1

proc incHighlighted(fl: var FileList) =
  if fl.highlighted < fl.files.len - 1:
    fl.highlighted += 1

proc tryEnter(fl: FileList): FileList =
  let selectedFile = fl.files[fl.highlighted]
  if selectedFile.kind == PathComponent.pcDir:
    return getFileList(selectedFile.path)
  else:
    return fl

proc tryParent(fl: FileList): FileList =
  let parentDir = parentDir(fl.absPath)
  if parentDir != "":
    return getFileList(parentDir)
  else:
    return fl


proc initWindow(): WindowPtr =
  var win = initscr()
  noecho()
  curs_set(0)
  start_color()
  use_default_colors()
  #assume_default_colors()

  win.keypad(true) # get function keys
  return win


proc drawFiles(window: WindowPtr, fileList: FileList) =
  window.wclear()
  window.wmove(0, 0)
  window.waddstr(&"{fileList.absPath}")

  let colorFile = 1.cshort
  let colorDir = 2.cshort
  discard init_pair(colorFile, COLOR_WHITE, -1)
  discard init_pair(colorDir, COLOR_BLUE, -1)

  window.wmove(2, 0)
  for i, file in fileList.files:
    let color =
      if file.kind == pcFile or file.kind == pcLinkToFile:
        colorFile
      else:
        colorDir

    # set attr
    window.wattron(COLOR_PAIR(color))
    if i == fileList.highlighted:
      window.wattron(A_REVERSE)

    let filename = file.path.extractFilename
    window.waddstr(&"{filename:-60s}\n")

    # restore attr
    window.wattroff(COLOR_PAIR(color))
    if i == fileList.highlighted:
      window.wattroff(A_REVERSE)
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
  var fileList = getFileList()

  #drawTestColor(window)

  let keypressLog = open(".keypresses", fmWrite)

  while true:
    drawFiles(window, fileList)
    let ch = window.wgetch()
    keypressLog.writeLine(ch)

    case ch
    of 'q'.ord():
      break
    of KEY_UP:
      fileList.decHighlighted()
    of KEY_DOWN:
      fileList.incHighlighted()
    of 10:  # ENTER
      fileList = fileList.tryEnter()
    of 263:  # BACKSPACE
      fileList = fileList.tryParent()
    else:
      discard

  endwin()


main()
#addstr("hello world")
#discard refresh()
#discard getch()
