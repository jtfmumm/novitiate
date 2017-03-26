use "../datast"
use "../display"
use "../input"

// Used to freely look around and inspect map with cursor in LookMode.
actor Looker
  var _world: World tag
  let _display: Display tag
  var _h: I32
  var _w: I32
  var _pos: Pos val = Pos(0, 0)
  var _focus: Pos val = Pos(0, 0)
  var _min_x: I32 = 0
  var _max_x: I32 = 0
  var _min_y: I32 = 0
  var _max_y: I32 = 0

  new create(w: World tag, focus: Pos val, display_h: I32, display_w: I32,
    display: Display tag)
  =>
    _world = w
    _display = display
    _h = display_h
    _w = display_w
    set_coords(focus)

  be update_world(w: World tag) =>
    _world = w

  be init(h: I32, w: I32, pos: Pos val, world: World tag) =>
    _h = h
    _w = w
    _world = world
    set_coords(pos)
    _world.highlight(_pos)
    _world.display_map(h, w, _focus, _display)

  fun ref set_coords(pos: Pos val) =>
    _pos = pos
    _focus = pos
    let x = _pos.x
    let y = _pos.y
    _min_x = (x - (_w / 2)) - 1
    _max_x = (x + (_w / 2)) + 1
    _min_y = (y - (_h / 2)) - 1
    _max_y = (y + (_h / 2)) + 1

  be close(h: I32, w: I32, focus: Pos val) =>
    _world.unhighlight(_pos)
    _world.display_map(h, w, focus, _display)

  be apply(cmd: Cmd val) =>
    match cmd
    | LeftCmd =>
      let try_pos = _pos + Directions.left()
      if try_pos.x > _min_x then
        _world.unhighlight(_pos)
        _pos = try_pos
        _world.highlight(_pos)
      end
    | RightCmd =>
      let try_pos = _pos + Directions.right()
      if try_pos.x < _max_x then
        _world.unhighlight(_pos)
        _pos = try_pos
        _world.highlight(_pos)
      end
    | UpCmd =>
      let try_pos = _pos + Directions.up()
      if try_pos.y > _min_y then
        _world.unhighlight(_pos)
        _pos = try_pos
        _world.highlight(_pos)
      end
    | DownCmd =>
      let try_pos = _pos + Directions.down()
      if try_pos.y < _max_y then
        _world.unhighlight(_pos)
        _pos = try_pos
        _world.highlight(_pos)
      end
    | EnterCmd =>
      _world.describe(_pos, _display)
    end
    _world.display_map(_h, _w, _focus, _display)

