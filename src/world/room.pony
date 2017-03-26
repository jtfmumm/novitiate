use "../datast"

class Room
  let _shape: RoomShape val

  new create(shape: RoomShape val) =>
    _shape = shape

  fun discover(t: Tiles) => 
    for pos in _shape.perimeter() do
      t.discover(pos)
    end

  fun rand_interior_position(): Pos val => _shape.rand_interior_position()
