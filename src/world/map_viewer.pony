use "../datast"
use "../display"
use "../input"

// Used to look around map by jumping screens in MapViewMode.
actor MapViewer
  var _world: World tag
  let _display: Display tag
  let _h: I32
  let _h_jump: I32
  let _w: I32
  let _w_jump: I32
  var _focus: Pos val = Pos(0, 0)

  new create(w: World tag, focus: Pos val, display_h: I32, display_w: I32,
    display: Display tag)
  =>
    _world = w
    _display = display
    _h = display_h
    _h_jump = _h / 4
    _w = display_w
    _w_jump = _w / 4

  be update_world(w: World tag) =>
    _world = w

  be init(pos: Pos val, world: World tag) =>
    _world = world
    _focus = pos
    _world.display_map(_h, _w, _focus, _display)

  be close(focus: Pos val) =>
    _world.display_map(_h, _w, focus, _display)

  be apply(cmd: Cmd val) =>
    match cmd
    | LeftCmd =>
      let old = _focus
      _focus = _focus + (Directions.left() * _w_jump)
      _display_from(old, _focus)
    | RightCmd =>
      let old = _focus
      _focus = _focus + (Directions.right() * _w_jump)
      _display_from(old, _focus)
    | UpCmd =>
      let old = _focus
      _focus = _focus + (Directions.up() * _h_jump)
      _display_from(old, _focus)
    | DownCmd =>
      let old = _focus
      _focus = _focus + (Directions.down() * _h_jump)
      _display_from(old, _focus)
    end

  fun _display_from(origin: Pos val, target: Pos val) =>
    for pos in PosStraightIterator(origin, target) do
      _world.display_map(_h, _w, pos, _display)
    end
