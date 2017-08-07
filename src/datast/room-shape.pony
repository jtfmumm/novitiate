use "collections"
use "debug"
use "../rand"

trait RoomShape
  fun perimeter_space(i: USize): Pos val ?

  fun rand_position(): Pos val =>
    let roll = Rand.usize_between(0, perimeter_size() - 1)
    try perimeter_space(roll)? else Pos(0, 0) end

  fun rand_interior_position(): Pos val

  fun perimeter(): Iterator[Pos val] => RoomShapePerimeter(this)

  fun interior(): Iterator[Pos val]

  fun all(): Iterator[Pos val] =>
    let arr: Array[Iterator[Pos val]] = Array[Iterator[Pos val]]
    arr.push(perimeter())
    arr.push(interior())
    Iterators[Pos val](consume arr)

  fun perimeter_size(): USize

class RoomShapePerimeter is Iterator[Pos val]
  let _shape: RoomShape box
  var _i: USize = 0

  new create(shape: RoomShape box) =>
    _shape = shape

  fun has_next(): Bool =>
    _i < _shape.perimeter_size()

  fun ref next(): Pos val ? =>
    _shape.perimeter_space(_i = _i + 1)?

  fun ref rewind(): RoomShapePerimeter =>
    _i = 0
    this

class RectRoom is RoomShape
  let _tlx: I32
  let _tly: I32
  let _brx: I32
  let _bry: I32
  let _pt1: I32
  let _pt2: I32
  let _pt3: I32
  let _perimeter_size: USize

  new val create(tl: Pos val, br: Pos val) =>
    _tlx = tl.x
    _tly = tl.y
    _brx = br.x
    _bry = br.y
    _pt1 = _brx - _tlx
    _pt2 = _pt1 + ((_bry + 1) - _tly)
    _pt3 = _pt2 + (_brx - _tlx)
    _perimeter_size = (((_brx - _tlx) * 2) + ((_bry - _tly) * 2)).usize()

  fun perimeter_space(i': USize): Pos val ? =>
    let i = i'.i32()
    if (i < 0) or (i >= _perimeter_size.i32()) then error end
    let x =
      if i < _pt1 then
        i + _tlx
      elseif i < _pt2 then
        _brx
      elseif i < _pt3 then
        let diff = (i - _pt2) + 1
        _brx - diff
      else
        _tlx
      end
    let y =
      if i < (_pt1 + 1) then
        _tly
      elseif i < _pt2 then
        let diff = i - _pt1
        _tly + diff
      elseif i < _pt3 then
        _bry
      else
        let diff = (i - _pt3) + 1
        _bry - diff
      end
    Pos(x, y)

  fun interior(): Iterator[Pos val] => RectInterior(this)

  fun rand_interior_position(): Pos val =>
    let area = interior_width() * interior_height()
    let roll = Rand.i32_between(0, area - 1)
    let x = (roll % interior_width()) + interior_starting_pos().x
    let y = (roll / interior_width()) + interior_starting_pos().y
    Pos(x, y)

  fun perimeter_size(): USize => _perimeter_size

  fun interior_width(): I32 => (_brx - _tlx) - 1
  fun interior_height(): I32 => (_bry - _tly) - 1
  fun interior_starting_pos(): Pos val => Pos(_tlx + 1, _tly + 1)

class RectInterior is Iterator[Pos val]
  let _rect: RectRoom box
  var _y: I32
  var _x: I32
  var _height: I32
  var _width: I32
  var _y_idx: I32 = 0
  var _x_idx: I32 = 0

  new create(rect: RectRoom box) =>
    _rect = rect
    let start_pos = _rect.interior_starting_pos()
    _x = start_pos.x
    _y = start_pos.y
    _height = _rect.interior_height()
    _width = _rect.interior_width()

  fun has_next(): Bool => _y_idx < _height

  fun ref next(): Pos val =>
    let pos = Pos(_x, _y)
    if _x_idx < (_width - 1) then
      _x = _x + 1
      _x_idx = _x_idx + 1
    else
      _y = _y + 1
      _y_idx = _y_idx + 1
      _x = _rect.interior_starting_pos().x
      _x_idx = 0
    end
    pos

class DiamondRoom is RoomShape
  let _internal: RoomShape val

  new val create(left: Pos val, right: Pos val) =>
    if ((right.x - left.x) % 2) == 0 then
      _internal = OddDiamondRoom(left, right)
    else
      _internal = EvenDiamondRoom(left, right)
    end

  fun perimeter_space(i: USize): Pos val ? => _internal.perimeter_space(i)?
  fun rand_position(): Pos val => _internal.rand_position()
  fun rand_interior_position(): Pos val => _internal.rand_interior_position()
  fun perimeter(): Iterator[Pos val]^ => _internal.perimeter()
  fun interior(): Iterator[Pos val] => _internal.interior()
  fun perimeter_size(): USize => _internal.perimeter_size()

class OddDiamondRoom is RoomShape
  let _lx: I32
  let _ly: I32
  let _rx: I32
  let _ry: I32
  let _radius: I32
  let _perimeter_size: USize
  let _pt1: I32
  let _pt2: I32
  let _pt3: I32

  new val create(left: Pos val, right: Pos val) =>
    _lx = left.x
    _ly = left.y
    _rx = right.x
    _ry = right.y
    let space = (_rx - _lx) - 1
    _radius = (space.f64() / 2).ceil().i32()
    _perimeter_size = (_radius * 4).usize()
    _pt1 = _radius
    _pt2 = _pt1 + _radius
    _pt3 = _pt2 + _radius

  fun perimeter_space(i': USize): Pos val ? =>
    let i = i'.i32()
    if (i < 0) or (i >= _perimeter_size.i32()) then error end
    let x =
      if i <= _pt2 then
        i + _lx
      else
        _rx - (i - _pt2)
      end
    let y =
      if i <= _pt1 then
        _ly + i
      elseif i <= _pt2 then
        (_ly + _radius) - (i - _pt1)
      elseif i <= _pt3 then
        _ly - (i - _pt2)
      else
        (_ly - _radius) + (i - _pt3)
      end
    Pos(x, y)

  fun perimeter_size(): USize => _perimeter_size

  fun interior(): Iterator[Pos val] => OddDiamondInterior(this)

  fun rand_interior_position(): Pos val =>
    // let area = (_radius * _radius) + ((_radius - 1) * (_radius - 1))
    // let roll = Rand.usize_between(0, area - 1)
    let x = ((_rx - _lx) / 2) + _lx
    let y = (((_ly + (_radius - 1)) - (_ly - (_radius - 1))) / 2)
      + (_ly - (_radius - 1))
    Pos(x, y)

  fun radius(): I32 => _radius
  fun left_pos(): Pos val => Pos(_lx, _ly)
  fun right_pos(): Pos val => Pos(_rx, _ry)
  fun interior_width(): I32 => (_rx - _lx) - 1

class OddDiamondInterior is Iterator[Pos val]
  let _diamond: OddDiamondRoom box
  var _y: I32
  var _x: I32
  var _radius: I32
  var _width: I32
  var _current_radius: I32 = 0
  var _y_idx: I32 = 0
  var _x_idx: I32 = 0

  new create(diamond: OddDiamondRoom box) =>
    _diamond = diamond
    _x = _diamond.left_pos().x + 1
    _y = _diamond.left_pos().y
    _radius = _diamond.radius()
    _width = _diamond.interior_width()

  fun has_next(): Bool => _x_idx < _width

  fun ref next(): Pos val =>
    let pos = Pos(_x, _y)
    if _y_idx < (_current_radius * 2) then
      _y = _y + 1
      _y_idx = _y_idx + 1
    else
      _x = _x + 1
      _y_idx = 0
      _x_idx = _x_idx + 1
      if _x_idx < _radius then
        _current_radius = _current_radius + 1
      else
        _current_radius = _current_radius - 1
      end
      _y = _diamond.left_pos().y - _current_radius
    end
    pos

class EvenDiamondRoom is RoomShape
  let _lx: I32
  let _ly: I32
  let _rx: I32
  let _ry: I32
  let _radius: I32
  let _perimeter_size: USize
  let _pt1: I32
  let _pt2: I32
  let _pt3: I32

  new val create(left: Pos val, right: Pos val) =>
    _lx = left.x
    _ly = left.y
    _rx = right.x
    _ry = right.y
    let space = (_rx - _lx) - 1
    _radius = (space.f64() / 2).ceil().i32()
    _perimeter_size = ((_radius * 4) + 2).usize()
    _pt1 = _radius
    _pt2 = (_pt1 + _radius) + 1
    _pt3 = _pt2 + _radius

  fun perimeter_space(i': USize): Pos val ? =>
    let i = i'.i32()
    if (i < 0) or (i >= _perimeter_size.i32()) then error end
    let x =
      if i <= _pt2 then
        _lx + i
      else
        _rx - (i - _pt2)
      end
    let y =
      if i <= _pt1 then
        _ly + i
      elseif i <= _pt2 then
        (_ly + _radius) - ((i - _pt1) - 1)
      elseif i <= _pt3 then
        _ly - (i - _pt2)
      else
        (_ly - _radius) + ((i - _pt3) - 1)
      end
    Pos(x, y)

  fun interior(): Iterator[Pos val] => EvenDiamondInterior(this)

  fun rand_interior_position(): Pos val =>
    let x = (_rx - _lx) / 2
    let y = ((_ly + (_radius - 1)) - (_ly - (_radius - 1))) / 2
    Pos(x, y)

  fun perimeter_size(): USize => _perimeter_size

  fun radius(): I32 => _radius
  fun left_pos(): Pos val => Pos(_lx, _ly)
  fun right_pos(): Pos val => Pos(_rx, _ry)
  fun interior_width(): I32 => (_rx - _lx) - 1

class EvenDiamondInterior is Iterator[Pos val]
  let _diamond: EvenDiamondRoom box
  var _y: I32
  var _x: I32
  var _radius: I32
  var _width: I32
  var _current_radius: I32 = 0
  var _y_idx: I32 = 0
  var _x_idx: I32 = 0

  new create(diamond: EvenDiamondRoom box) =>
    _diamond = diamond
    _x = _diamond.left_pos().x + 1
    _y = _diamond.left_pos().y
    _radius = _diamond.radius()
    _width = _diamond.interior_width()

  fun has_next(): Bool => _x_idx < _width

  fun ref next(): Pos val =>
    let pos = Pos(_x, _y)
    if _y_idx < (_current_radius * 2) then
      _y = _y + 1
      _y_idx = _y_idx + 1
    else
      _x = _x + 1
      _y_idx = 0
      _x_idx = _x_idx + 1
      if _x_idx < _radius then
        _current_radius = _current_radius + 1
      elseif _x_idx > _radius then
        _current_radius = _current_radius - 1
      end
      _y = _diamond.left_pos().y - _current_radius
    end
    pos





