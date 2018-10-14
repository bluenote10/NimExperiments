import ncurses

var scr = initscr()
scr.keypad(false)
noecho()

addstr("hello world")
discard refresh()
discard getch()

endwin()