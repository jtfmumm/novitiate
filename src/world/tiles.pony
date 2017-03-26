use "collections"
use "../datast"

class Tiles
  let _h: I32
  let _w: I32
  let _data: Array[Tile]
  let _rooms: Map[U128, Room val] = Map[U128, Room val]
  let _room_list: Array[Room val] = Array[Room val]
  let _room_shapes: RangedArray[RoomShape val] = RangedArray[RoomShape val]
  let _absolute_top_left: Pos val

  new create(h': I32, w': I32, data_gen: ({(): Tile} val | None) = None,
    absolute_top_left': Pos val = Pos(0, 0)) 
  =>
    _h = h'
    _w = w'
    _absolute_top_left = absolute_top_left'
    let cell_count = (_h * _w).usize()
    _data = Array[Tile](cell_count)
    match data_gen
    | let f: {(): Tile} val =>
      for cell in Range(0, cell_count) do
        _data.push(f())
      end
    else
      for cell in Range(0, cell_count) do
        _data.push(Tile.empty())
      end
    end

  new iso _from(h': I32, w': I32, d: Array[Tile] iso, 
    absolute_top_left': Pos val = Pos(0, 0)) 
  =>
    _h = h'
    _w = w'
    _data = consume d
    _absolute_top_left = absolute_top_left'

  fun _to_cell(pos: Pos val): USize =>
    ((_w * pos.y) + pos.x).usize()

  fun _in_bounds(pos: Pos val): Bool =>
    (pos.y >= 0) and (pos.y < _h) and
      (pos.x >= 0) and (pos.x < _w)

  fun ref apply(pos: Pos val): Tile ? =>
    if _in_bounds(pos) then
      _data(_to_cell(pos))
    else
      error
    end

  fun h(): I32 => _h
  fun w(): I32 => _w

  fun ref add_room(id: U128, shape: RoomShape val) => 
    let r: Room val = recover Room(shape) end
    _rooms(id) = r
    _room_list.push(r)
    _room_shapes.add(shape, shape.perimeter_size())

  // fun ref add_room_shape(room_shape: RoomShape val) =>
  //   _room_shapes.add(room_shape, room_shape.perimeter_size())

  fun ref discover_room(id: U128) => try _rooms(id).discover(this) end 

  fun ref discover(pos: Pos val) => try apply(pos).discover() end

  fun ref update(pos: Pos val, value: Tile) ? =>
    if _in_bounds(pos) then
       _data(_to_cell(pos)) = value
    else
      @printf[I32](("Matrix Write Error: Out of bounds\n").cstring())
      error
    end

  fun ref submap(h': I32, w': I32, top_left_cell: Pos val, 
    create_void: ({(): Tile} val) = {(): Tile => Tile.empty()}): 
    Tiles iso^
  =>
    let data: Array[Tile] iso = recover Array[Tile] end
    for row in Range(0, h'.usize()) do
      for col in Range(0, w'.usize()) do
        let x = col.i32() + top_left_cell.x
        let y = row.i32() + top_left_cell.y
        let tile = 
          try
            apply(Pos(x, y))
          else
            create_void()
          end
        data.push(tile.clone())
      end
    end
    Tiles._from(h', w', consume data, top_left_cell)

  fun relative_pos_for(abs: Pos val): Pos val =>
    abs - _absolute_top_left

  fun room_shapes(): this->RangedArray[RoomShape val] => _room_shapes

  fun room_count(): USize => _room_list.size()

  fun room(idx: USize): Room val ? => _room_list(idx)

  fun ref highlight(pos: Pos val) => try apply(pos).highlight() end

  fun ref unhighlight(pos: Pos val) => try apply(pos).unhighlight() end
