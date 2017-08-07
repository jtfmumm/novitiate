use "../datast"

primitive LineOfSight
  fun apply(pos1: Pos val, pos2: Pos val, ts: Tiles iso): Bool =>
    let tiles: Tiles = consume ts
    let arr: Array[Pos val] iso = recover Array[Pos val] end
    let iter = LineIterator(pos1, pos2)
    for pos in iter do
      try
        let t = tiles(pos)?
        if t.is_transparent() then
          if pos == pos1 then return true end
        else
          if pos == pos1 then return true end
          return false
        end
      end
    end
    false

  fun visible_along(pos1: Pos val, pos2: Pos val, ts: Tiles iso): 
    Seq[Pos val] 
  =>
    let tiles: Tiles = consume ts
    let arr: Array[Pos val] iso = recover Array[Pos val] end
    let iter = LineIterator(pos1, pos2)
    for pos in iter do
      try
        let t = tiles(pos)?
        if t.is_transparent() then
          arr.push(pos)
        else
          arr.push(pos)
          break
        end
      end
    end
    consume arr

class LineIterator is Iterator[Pos val]
  var _idx: USize = 0
  let _pos1: Pos val
  let _pos2: Pos val
  let _output_pos_builder: {(I32, I32): Pos val} val
  var _dx: I32
  var _dy: I32
  var _d: I32
  var _x: I32
  var _y: I32
  var _done: Bool = false

  new create(pos1: Pos val, pos2: Pos val) =>
    let octant = Octants.find_octant(pos1, pos2)
    let input_pos_builder = Octants.input_pos_builder(octant)
    _pos1 = input_pos_builder(pos1.x, pos1.y)
    _pos2 = input_pos_builder(pos2.x, pos2.y)
    _output_pos_builder = Octants.output_pos_builder(octant)
    _dx = _pos2.x - _pos1.x
    _dy = _pos2.y - _pos1.y
    _d = _dy - _dx
    _x = _pos1.x
    _y = _pos1.y

  fun ref has_next(): Bool => not _done

  fun ref next(): Pos val =>
    let n = _output_pos_builder(_x, _y)
    if (_x == _pos2.x) and (_y == _pos2.y) then _done = true end
    if _d >= 0 then
      _y = _y + 1
      _d = _d - _dx
    end
    _d = _d + _dy
    _x = _x + 1
    n

primitive Octants
  fun find_octant(pos1: Pos val, pos2: Pos val): I32 =>
    let dx = pos2.x - pos1.x
    let dy = pos2.y - pos1.y

    // Octant 0-1
    if (dx >= 0) and (dy >= 0) then
      if (dx - dy) >= 0 then 0 else 1 end
    // Octant 2-3
    elseif (dx < 0) and (dy >= 0) then
      if (-dx - dy) <= 0 then 2 else 3 end
    // Octant 4-5
    elseif (dx < 0) and (dy < 0) then
      if (-dx + dy) >= 0 then 4 else 5 end
    // Octant 6-7
    elseif (dx >= 0) and (dy < 0) then
      if (dx + dy) <= 0 then 6 else 7 end
    else
      0
    end

  fun input_pos_builder(octant: I32): {(I32, I32): Pos val} val =>
    match octant
    | 0 => {(x: I32, y: I32): Pos val => Pos(x, y)}
    | 1 => {(x: I32, y: I32): Pos val => Pos(y, x)}
    | 2 => {(x: I32, y: I32): Pos val => Pos(y, -x)}
    | 3 => {(x: I32, y: I32): Pos val => Pos(-x, y)}
    | 4 => {(x: I32, y: I32): Pos val => Pos(-x, -y)}
    | 5 => {(x: I32, y: I32): Pos val => Pos(-y, -x)}
    | 6 => {(x: I32, y: I32): Pos val => Pos(-y, x)}
    | 7 => {(x: I32, y: I32): Pos val => Pos(x, -y)}
    else
      {(x: I32, y: I32): Pos val => Pos(x, y)}
    end

  fun output_pos_builder(octant: I32): {(I32, I32): Pos val} val =>
    match octant
    | 0 => {(x: I32, y: I32): Pos val => Pos(x, y)}
    | 1 => {(x: I32, y: I32): Pos val => Pos(y, x)}
    | 2 => {(x: I32, y: I32): Pos val => Pos(-y, x)}
    | 3 => {(x: I32, y: I32): Pos val => Pos(-x, y)}
    | 4 => {(x: I32, y: I32): Pos val => Pos(-x, -y)}
    | 5 => {(x: I32, y: I32): Pos val => Pos(-y, -x)}
    | 6 => {(x: I32, y: I32): Pos val => Pos(y, -x)}
    | 7 => {(x: I32, y: I32): Pos val => Pos(x, -y)}
    else
      {(x: I32, y: I32): Pos val => Pos(x, y)}
    end
