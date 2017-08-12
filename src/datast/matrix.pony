use "collections"

class Matrix[A: Any #read]
  let _h: I32
  let _w: I32
  let _data: Array[(A | None)]

  new create(h: I32, w: I32, data_gen: ({(): A^} val | None) = None) =>
    _h = h
    _w = w
    let cell_count = (_h * _w).usize()
    _data = Array[(A | None)](cell_count)
    match data_gen
    | let f: {(): A} val =>
      for cell in Range(0, cell_count) do
        _data.push(f())
      end
    else
      for cell in Range(0, cell_count) do
        _data.push(None)
      end
    end

  fun _to_cell(pos: Pos val): USize =>
    ((_w * pos.y) + pos.x).usize()

  fun _in_bounds(pos: Pos val): Bool =>
    (pos.y >= 0) and (pos.y < _h) and
      (pos.x >= 0) and (pos.x < _w)

  fun ref apply(pos: Pos val): A ? =>
    if _in_bounds(pos) then
      match _data(_to_cell(pos))?
      | let a: A => a
      else
        @printf[I32](("Matrix Read Error\n").cstring())
        error
      end
    else
      error
    end

  fun ref update(pos: Pos val, value: A) ? =>
    if _in_bounds(pos) then
       _data(_to_cell(pos))? = value
    else
      @printf[I32](("Matrix Write Error: Out of bounds\n").cstring())
      error
    end
