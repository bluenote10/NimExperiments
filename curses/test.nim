import ncurses
import os
import strutils
import sequtils
import sugar
import strformat
import algorithm

import terminal
import colors
import tables


type
  WindowPtr = ptr window

  File = tuple[kind: PathComponent, path: string]

  FileList = object
    absPath: string
    files: seq[File]
    filesFiltered: seq[File]
    previousHighlights: TableRef[string, string]
    search: string
    highlighted: int
    scrollOffset: int

proc isDir(a: File): bool =
  a.kind == pcDir or a.kind == pcLinkToDir

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

proc getFileList(directory=getCurrentDir(), previousHighlights=newTable[string, string]()): FileList =
  let files = toSeq(walkDir(directory)).sorted(cmpFile)
  FileList(
    absPath: absolutePath(directory),
    files: files,
    filesFiltered: files,
    previousHighlights: previousHighlights,
    search: "",
    highlighted: 0,
    scrollOffset: 0,
  )

proc decHighlighted(fl: var FileList) =
  if fl.highlighted > 0:
    fl.highlighted -= 1

proc incHighlighted(fl: var FileList) =
  if fl.highlighted < fl.files.len - 1:
    fl.highlighted += 1

proc getHighlighted(fl: FileList): File =
  fl.filesFiltered[fl.highlighted]

proc tryHighlight(fl: var FileList, toHighlight: string) =
  for i, file in fl.filesFiltered:
    if file.path.extractFilename == toHighlight:
      fl.highlighted = i

proc tryEnter(fl: FileList): FileList =
  let selectedFile = fl.filesFiltered[fl.highlighted]
  if selectedFile.isDir():
    var newFileList = getFileList(selectedFile.path, previousHighlights=fl.previousHighlights)
    if fl.previousHighlights.hasKey(newFileList.absPath):
      newFileList.tryHighlight(fl.previousHighlights[newFileList.absPath])
    return newFileList
  else:
    return fl

proc tryParent(fl: FileList): FileList =
  let parentDir = parentDir(fl.absPath)
  if parentDir != "":
    fl.previousHighlights[fl.absPath] = fl.getHighlighted().path.extractFilename
    var newFileList = getFileList(parentDir, previousHighlights=fl.previousHighlights)
    newFileList.tryHighlight(fl.absPath.extractFilename)
    return newFileList
  else:
    return fl

proc updateFiltered(fl: var FileList) =
  let searchTerms = fl.search.splitWhitespace()

  fl.filesFiltered.setLen(0)
  for file in fl.files:
    var matchesAll = true
    for term in searchTerms:
      if not file.path.extractFilename.toLowerAscii.contains(term.toLowerAscii):
        matchesAll = false
    if matchesAll:
      fl.filesFiltered.add(file)

  fl.highlighted = 0
  fl.scrollOffset = 0


proc initWindow(): WindowPtr =
  var win = initscr()
  noecho()
  raw()
  curs_set(0)
  start_color()
  use_default_colors()
  #assume_default_colors()

  win.keypad(true) # get function keys
  #win.nodelay(true)
  return win


proc drawFiles(window: WindowPtr, fileList: FileList) =
  window.werase() # seems to be better the wclear
  window.wmove(0, 0)
  window.waddstr(&"{fileList.absPath}")

  window.wmove(2, 0)
  window.waddstr(&"{fileList.search}")

  let colorFile = 1.cshort
  let colorDir = 2.cshort
  discard init_pair(colorFile, COLOR_WHITE, -1)
  discard init_pair(colorDir, COLOR_BLUE, -1)

  window.wmove(4, 0)
  for i, file in fileList.filesFiltered:
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


proc drawTestColor1(window: WindowPtr) =
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


proc drawTestColor2(window: WindowPtr) =
  enableTrueColors()
  window.wmove(0, 0)
  for i in 1 .. 10:
    let color = rgb(100, 100, i * 20)
    window.waddstr(&"{ansiForegroundColorCode(color)} {i} ")
  window.wrefresh()


proc drawTestColor3() =
  enableTrueColors()
  for i in 1 .. 10:
    let color = rgb(100, 100, i * 20)
    #echo &"{ansiForegroundColorCode(color)} {i} "
    setForegroundColor(color)
    echo i


proc main() =
  var window = initWindow()
  var fileList = getFileList()

  #drawTestColor(window)
  #drawTestColor2(window)
  #let ch = window.wgetch()

  let keypressLog = open(".keypresses", fmWrite)

  while true:
    drawFiles(window, fileList)
    let ch = window.wgetch()
    keypressLog.writeLine(ch)

    case ch
    of 'q'.ord():
      break
    of KEY_UP, 'K'.ord():
      fileList.decHighlighted()
    of KEY_DOWN, 'J'.ord():
      fileList.incHighlighted()
    of 10:  # ENTER
      fileList = fileList.tryEnter()
    of 263:  # BACKSPACE
      if fileList.search.len > 0:
        fileList.search.setLen(fileList.search.len - 1)
        fileList.updateFiltered()
      else:
        fileList = fileList.tryParent()
    else:
      fileList.search &= ch.char
      fileList.updateFiltered()

  endwin()


main()
#addstr("hello world")
#discard refresh()
#discard getch()
