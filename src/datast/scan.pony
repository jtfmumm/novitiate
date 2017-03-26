class Scan
  let _tlx: I32
  let _tly: I32
  let _w: I32
  let _h: I32

  new create(tl: Pos val, h: I32, w: I32) =>
    _tlx = tl.x
    _tly = tl.y
    _w = w
    _h = h

  fun apply(): Iterator[Pos val] => ScanIterator(this, _h, _w)
  fun starting_pos(): Pos val => Pos(_tlx, _tly)

class ScanIterator is Iterator[Pos val]
  let _scan: Scan box
  var _y: I32 
  var _x: I32 
  var _h: I32
  var _w: I32
  var _y_idx: I32 = 0
  var _x_idx: I32 = 0

  new create(scan: Scan box, h: I32, w: I32) =>
    _scan = scan
    let start_pos = _scan.starting_pos()
    _x = start_pos.x
    _y = start_pos.y
    _h = h
    _w = w

  fun has_next(): Bool => _y_idx < _h

  fun ref next(): Pos val =>
    let pos = Pos(_x, _y)
    if _x_idx < (_w - 1) then
      _x = _x + 1
      _x_idx = _x_idx + 1
    else
      _y = _y + 1
      _y_idx = _y_idx + 1
      _x = _scan.starting_pos().x
      _x_idx = 0
    end
    pos

class ScanClose is Iterator[Pos val]
  var _pos: Pos val
  let _diffs: Array[Pos val] = [Pos(-1, -1), Pos(0, -1), Pos(1, -1),
                                Pos(-1, 0),              Pos(1, 0),
                                Pos(-1, 1),  Pos(0, 1),  Pos(1, 1)]
  var _idx: USize = 0

  new create(pos: Pos val) =>
    _pos = pos

  fun ref apply(pos: Pos val): ScanClose =>
    _pos = pos
    _idx = 0
    this

  fun has_next(): Bool => _idx < 8

  fun ref next(): Pos val =>
    let pos =
      try
        _pos + _diffs(_idx)
      else
        Pos(-1, -1)
      end
    _idx = _idx + 1
    pos 
