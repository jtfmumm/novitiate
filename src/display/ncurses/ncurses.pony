use "lib:ncurses"

primitive Window

primitive Nc
  // Windows
  fun initscr(): Pointer[Window] => @initscr[Pointer[Window]]()
  fun newwin(nlines: I32, ncolumns: I32, begin_y: I32, begin_x: I32)
    : Pointer[Window] =>
    @newwin[Pointer[Window]](nlines, ncolumns, begin_y, begin_x)
  fun delwin(w: Pointer[Window]) => @delwin[None](w)
  fun endwin() => @endwin[None]()

  // Initialization
  fun noecho() => @noecho[None]()
  fun cbreak() => @cbreak[None]()
  fun keypad(w: Pointer[Window], bf: Bool) =>
    @keypad[None](w, bf)
  fun curs_set(option: I32) => @curs_set[None](option)

  // State changes
  fun clear() => @clear[None]()
  fun wclear(window: Pointer[Window]) => @wclear[None](window)
  fun refresh() => @refresh[None]()
  fun wrefresh(window: Pointer[Window]) => @wrefresh[None](window)
  fun erase(row: I32, column: I32) => @erase[None](row, column)

  // Output
  fun printw(s: String) => @printw[None](s.cstring())
  fun wprintw(window: Pointer[Window], s: String) => @wprintw[None](window, s.cstring())
  fun mvprintw(row: I32, column: I32, s: String) =>
    @mvprintw[None](row, column, s.cstring())
  fun mvwprintw(window: Pointer[Window], row: I32, column: I32, s: String) =>
    @mvwprintw[None](window, row, column, s.cstring())
  fun mvaddch(row: I32, column: I32, char_string: String) =>
    try
      let char = char_string.array()(0)?
      @mvaddch[None](row, column, char)
    end
  fun mvwaddch(window: Pointer[Window], row: I32, column: I32,
    char_string: String) =>
    try
      let char = char_string.array()(0)?
      @mvwaddch[None](window, row, column, char)
    end

  // Input
  fun getch(): I32 => @getch[I32]()

  // Color
  fun start_color() => @start_color[None]()
  fun init_pair(pair_id: I32, foreground: I32, background: I32) =>
    @init_pair[None](pair_id, foreground, background)

  fun switch_on_pair(id: I32) => @attron[None](id << 8)
  fun wswitch_on_pair(window: Pointer[Window], id: I32) =>
    @wattron[None](window, id << 8)
  fun switch_off_pair(id: I32) => @attroff[None](id << 8)
  fun wswitch_off_pair(window: Pointer[Window], id: I32) =>
    @wattroff[None](window, id << 8)
