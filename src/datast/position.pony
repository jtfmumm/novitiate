class Pos is (Equatable[Pos] & Stringable)
  let x: I32
  let y: I32

  new val create(x': I32, y': I32) =>
    x = x'
    y = y'

  fun add(p: Pos val): Pos val =>
    Pos(x + p.x, y + p.y)

  fun sub(p: Pos val): Pos val =>
    Pos(x - p.x, y - p.y)

  fun mul(scalar: I32): Pos val =>
    Pos(scalar * x, scalar * y)

  fun eq(that: box->Pos): Bool =>
    (x == that.x) and (y == that.y)

  fun gt(that: box->Pos): Bool =>
    ((x >= that.x) and (y > that.y))
      or ((x > that.x) and (y >= that.y))

  fun lt(that: box->Pos): Bool =>
    ((x <= that.x) and (y < that.y))
      or ((x < that.x) and (y <= that.y))

  fun ge(that: box->Pos): Bool =>
    gt(that) or eq(that)

  fun le(that: box->Pos): Bool =>
    lt(that) or eq(that)

  fun string(): String iso^ =>
    let x_str: String iso = x.string().clone()
    let y_str: String iso = y.string().clone()
    recover String().>append("Pos(" + consume x_str + ", " + consume y_str + ")") end

class PosStraightIterator is Iterator[Pos val]
  let direction: Pos val
  var _x: I32
  var _y: I32
  var _idx: I32 = 0
  var _max: I32 = 0
  var _min: I32 = 0
  var _bias: I32 = 0

  new create(pos1: Pos val, pos2: Pos val) =>
    _x = pos1.x
    _y = pos1.y
    direction =
      if _x > pos2.x then
        _min = pos2.x
        _bias = -1
        _idx = _x
        Pos(-1, 0)
      elseif _x < pos2.x then
        _max = pos2.x
        _bias = 1
        _idx = _x
        Pos(1, 0)
      elseif _y > pos2.y then
        _min = pos2.y
        _bias = -1
        _idx = _y
        Pos(0, -1)
      elseif _y < pos2.y then
        _max = pos2.y
        _bias = 1
        _idx = _y
        Pos(0, 1)
      else
        _max = 0
        _bias = 1
        _idx = 0
        Pos(-1, -1)
      end

  fun has_next(): Bool =>
    if _bias == 1 then
      _idx < _max
    else
      _idx > _min
    end

  fun ref next(): Pos val =>
    _idx = _idx + _bias
    _x = _x + direction.x
    _y = _y + direction.y
    Pos(_x, _y)
