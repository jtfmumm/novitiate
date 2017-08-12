use "collections"
use "ncurses"
use "../agents"
use "../datast"
use "../help"
use "../inventory"
use "../world"

interface Display
  be apply(tiles: Tiles iso)
  be inventory(i: InventoryDisplayable val)
  be stats(s: Stats val)
  be log(s: String, color: I32 = 15)
  be help()
  be clear()
  be close()
  be close_with_message(msg: String)

actor EmptyDisplay
  let _env: (Env | None)

  new create(env: (Env | None) = None) =>
    _env = env

  be apply(tiles: Tiles iso) => None
  be inventory(i: InventoryDisplayable val) => None
  be stats(s: Stats val) => None
  be log(s: String, color: I32 = 15) =>
    match _env
    | let e: Env =>
      e.out.print(s)
    end

  be help() => None

  be clear()=> None

  be close() => None

  be close_with_message(msg: String) =>
    @printf[I32]((msg + "\n").cstring())

actor CursesDisplay
  let _world_height: I32
  let _world_width: I32
  let _log_width: I32
  let _log_msgs: Array[LogMsg val] = Array[LogMsg val]
  let _log_max: USize
  let _world_window: Pointer[Window]
  let _log_window: Pointer[Window]
  let _stats_window: Pointer[Window]

  new create(world_height: I32, world_width: I32, log_width: I32,
    stats_height: I32)
  =>
    _world_height = world_height
    _world_width = world_width
    _log_max = _world_height.usize()
    _log_width = log_width
    let parent = Nc.initscr()
    _world_window = Nc.newwin(_world_height, _world_width, 1, 2)
    _log_window = Nc.newwin(_world_height, _log_width, 0, _world_width + 10)
    _stats_window = Nc.newwin(stats_height, _world_width, _world_height + 1,
      2)
    Nc.clear()
    Nc.wclear(_world_window)
    Nc.wclear(_log_window)
    Nc.wclear(_stats_window)
    Nc.noecho()
    Nc.cbreak()
    Nc.keypad(parent, true)
    Nc.curs_set(0)
    _init()
    for i in Range[I32](0, 256) do
      Nc.switch_on_pair(i)
      // Nc.printw(i.string() + " ")
      Nc.switch_off_pair(i)
    end
    // Nc.getch()
    Nc.clear()

  be apply(tiles: Tiles iso) =>
    let t: Tiles ref = consume tiles
    for row in Range[I32](0, _world_height) do
      for col in Range[I32](0, _world_width) do
        try
          let tile: Tile = t(Pos(col, row))?
          if tile.is_visible() then
            let background =
              if tile.is_highlighted() then
                Colors.yellow()
              elseif tile.elevation >= 0 then
                ElevationColors(tile.elevation)
              else
                TerrainColors(tile.terrain)
              end
            let display_char =
              if tile.is_occupied() then
                DisplayChars(tile.occupant_code)
              elseif tile.has_item() then
                try
                  let i = tile.item as Item val
                  ItemDisplayChars(i)
                else
                  TerrainDisplayChars(tile.terrain)
                end
              elseif tile.has_landmark() then
                LandmarkDisplayChars(tile.landmark)
              else
                TerrainDisplayChars(tile.terrain)
              end
            _display_tile(row, col, display_char, background)
          else
            if tile.is_highlighted() then
              _display_tile(row, col, " ", Colors.yellow())
            elseif tile.has_staircase() and tile.has_been_seen() then
              _display_tile(row, col, LandmarkDisplayChars(tile.landmark),
                Colors.black())
            elseif tile.has_been_seen() then
              _display_tile(row, col, " ", Colors.black())
            else
              _display_tile(row, col, " ", TerrainColors(Undug))
            end
          end
        end
      end
    end
    Nc.refresh()
    Nc.wrefresh(_world_window)

  be inventory(inv: InventoryDisplayable val) =>
    Nc.wclear(_world_window)
    let categories = ["Weapons"; "Armor"; "Potions"; "Miscellaneous"]
    let mid_offset = _world_width / 2
    var line: I32 = 0
    var offset: I32 = 0
    for category in categories.values() do
      try
        let items = inv.items(category)?
        if items.size() > 0 then
          Nc.mvwprintw(_world_window, line, offset, category.upper())
          line = line + 1
          if (line > 27) and (offset == 0) then
            line = 0
            offset = mid_offset
          end
        end
        for (idx, v) in items.pairs() do
          let item = if inv.equipped.contains(category)
            and inv.equipped(category)?.contains(idx) then
            "  * " + v
          else
            "  " + v
          end
          let highlighted = (inv.highlighted._1 == category)
            and (idx == inv.highlighted._2)
          _display_item(line, item, highlighted, offset)
          line = line + 1
          if (line > 26) and (offset == 0) then
            line = 0
            offset = mid_offset
          end
        end
      end
    end
    Nc.refresh()
    Nc.wrefresh(_world_window)

  be help() =>
    Nc.wclear(_world_window)
    var line: I32 = 0
    for item in Help().values() do
      _display_item(line, item, false, 0)
      line = line + 1
    end
    Nc.refresh()
    Nc.wrefresh(_world_window)

  fun ref _display_item(line: I32, item: String, highlighted: Bool,
    offset: I32) =>
    if highlighted then
      Nc.wswitch_on_pair(_world_window, Colors.light_grey())
      Nc.mvwprintw(_world_window, line, offset, item)
      Nc.wswitch_off_pair(_world_window, Colors.light_grey())
    else
      Nc.mvwprintw(_world_window, line, offset, item)
    end

  be stats(s: Stats val) =>
    Nc.wclear(_stats_window)
    Nc.mvwprintw(_stats_window, 0, 0, s.string())
    Nc.refresh()
    Nc.wrefresh(_stats_window)

  fun ref _display_tile(row: I32, col: I32, display_char: String,
    background: I32) =>
    Nc.wswitch_on_pair(_world_window, background)
    Nc.mvwaddch(_world_window, row, col, display_char)
    Nc.wswitch_off_pair(_world_window, background)

  be log(s: String, color: I32 = 15) =>
    for msg in LogAppender(s, _log_width, color).values() do
      _log_msgs.push(msg)
    end

    while _log_msgs.size() > _log_max do
      try _log_msgs.shift()? end
    end
    _display_logs()

  be clear() =>
    Nc.wclear(_world_window)
    Nc.wclear(_log_window)
    Nc.wclear(_stats_window)

  fun _check_for_dash(s: String, orig_len: ISize, used: ISize): String =>
    if used < orig_len then
      s + "-"
    else
      s
    end

  fun ref _display_logs() =>
    Nc.wclear(_log_window)
    for i in Range[I32](1, _log_msgs.size().i32()) do
      try
        Nc.mvwprintw(_log_window, i, 0, _log_msgs(i.usize())?.msg)
      end
    end
    Nc.refresh()
    Nc.wrefresh(_log_window)

  fun _init() =>
    Nc.start_color()
    for i in Range[I32](0, 256) do
      Nc.init_pair(i, Colors.white(), i)
    end

  be close() =>
    _close()

  be close_with_message(msg: String) =>
    _close()
    @printf[I32]((msg + "\n").cstring())

  fun ref _close() =>
 	  // Clear ncurses data structures
 	  Nc.delwin(_world_window)
 	  Nc.delwin(_log_window)
 	  Nc.endwin()


primitive LogAppender
  fun apply(s: String, line_length: I32, color: I32 = 15):
    Array[LogMsg val] val
  =>
    let log_msgs: Array[LogMsg val] trn =
      recover Array[LogMsg val] end
    try
      let str_len = s.size().i32()
      if str_len <= line_length then
        log_msgs.push(LogMsg(s, color))
      else
        let words = recover val s.split(" ") end
        if words.size() == 0 then return consume log_msgs end

        var next_line = words(0)?

        for i in Range(1, words.size()) do
          let word = words(i)?
          if word == " " then continue end
          if (next_line.size() + word.size() + 1) <= line_length.usize() then
            next_line = next_line + " " + word
          else
            try
              if next_line(0)? == ' ' then
                next_line = next_line.substring(1, next_line.size().isize())
              end
            end
            log_msgs.push(LogMsg(next_line, color))
            next_line = word
          end
        end
        log_msgs.push(LogMsg(next_line, color))
      end
      consume log_msgs
    else
      recover [LogMsg("Error printing message!", color)] end
    end

primitive DisplayChars
  fun apply(code: I32): String =>
    match code
    | OccupantCodes.self() => "@"
    | OccupantCodes.raven() => "r"
    | OccupantCodes.goblin() => "g"
    | OccupantCodes.brigand() => "b"
    | OccupantCodes.ooze() => "o"
    | OccupantCodes.skeleton() => "s"
    | OccupantCodes.ekek() => "e"
    | OccupantCodes.hellhound() => "h"
    | OccupantCodes.cloaked_shadow() => "c"
    | OccupantCodes.mantis() => "m"
    | OccupantCodes.horror() => "H"
    | OccupantCodes.vampire() => "v"
    else
      " "
    end

primitive TerrainDisplayChars
  fun apply(t: Terrain val): String =>
    match t
    | Hill => "^"
    | Floor => "."
    | Wall => "#"
    | Door => "|"
    | Lava => "^"
    | Undug => " "
    | Void => " "
    else
      " "
    end

primitive LandmarkDisplayChars
  fun apply(l: Landmark): String =>
    match l
    | UpStairs => "<"
    | let d: DownStairs val => ">"
    else
      " "
    end

primitive ItemDisplayChars
  fun apply(i: Item val): String =>
    match i
    | let a: Armor val => "%"
    | let a: Weapon val => "%"
    | let a: Potion val => "!"
    | let a: Gold val => "$"
    else
      "?"
    end

class LogMsg
  let msg: String
  let color: I32

  new val create(m: String, c: I32) =>
    msg = m
    color = c
