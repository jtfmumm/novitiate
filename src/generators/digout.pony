use "time"
use "../datast"
use "../world"
use "../rand"
use "../guid"
use "../inventory"
use "collections"

primitive Digout
  fun apply(diameter: I32, starting_pos: Pos val, depth: I32,
    rand: Rand iso = recover Rand end): Tiles iso^
  =>
    let d: _Digout val = _Digout(diameter, starting_pos, depth)
    recover d(consume rand) end

class _Digout
  let diameter: I32
  let starting_pos: Pos val
  let depth: I32
  let max_depth: I32

  new val create(d: I32, spos: Pos val, dep: I32, max: I32 = 12) =>
    diameter = d
    starting_pos = spos
    depth = dep
    max_depth = max

  fun val apply(rand: Rand iso): Tiles iso^ =>
    // TODO: Use determinate seed
    let guid_gen: GuidGenerator = GuidGenerator()
    let d = diameter
    var tiles: Tiles iso = recover Tiles(d, d) end

    let w = rand.i32_between(3, 7)
    let h = rand.i32_between(3, 7)

    let shape = RectRoom(starting_pos - Pos(w, h), starting_pos + Pos(w, h))
    let guid = guid_gen()
    tiles.add_room(guid, shape)
    for pos in shape.perimeter() do
      try tiles(pos)? =
        recover
          Tile(EmptyOccupant, OccupantCodes.none(), Wall, -1
            where r_id = guid)
        end
      end
    end

    for pos in shape.interior() do
      try tiles(pos)? =
        recover
          Tile(EmptyOccupant, OccupantCodes.none(), Floor, -1
            where r_id = guid)
        end
      end
    end

    for i in Range(0, 200) do
      tiles = try_dig(consume tiles)
    end

    if depth < max_depth then
      tiles = add_downstairs(consume tiles)
    end

    consume tiles

  fun val try_dig(ts: Tiles iso): Tiles iso^ =>
    // TODO: Use determinate seed
    let guid_gen: GuidGenerator = GuidGenerator()
    let guid = guid_gen()
    let d = diameter
    recover
      var tiles: Tiles = consume ts
      try
        let shapes = tiles.room_shapes()
        let shapes_idx = Rand.usize_between(0, tiles.room_shapes().size())
        let shape = shapes(shapes_idx)?
        let pos_idx = Rand.usize_between(0, shape.perimeter_size())
        let pos = shape.perimeter_space(pos_idx)?

        let west = tiles(pos + Directions.left())?.is_diggable()
        let e = tiles(pos + Directions.right())?.is_diggable()
        let s = tiles(pos + Directions.down())?.is_diggable()
        let n = tiles(pos + Directions.up())?.is_diggable()

        let h = Rand.i32_between(3, 10)
        let w = Rand.i32_between(3, 20)

        if is_blocked(tiles, pos) then
          None
        elseif e then
          let offset = Rand.i32_between(-(h / 2), -1)
          tiles = try_room(tiles, pos, pos + Directions.right(),
            Pos(0, offset), h, w, guid)
        elseif west then
          let offset = Rand.i32_between(-(h / 2), -1)
          tiles = try_room(tiles, pos, pos + Directions.left(),
            Pos(-(w - 1), offset), h, w, guid)
        elseif s then
          let offset = Rand.i32_between(-(w / 2), -1)
          tiles = try_room(tiles, pos, pos + Directions.down(),
            Pos(offset, 0), h, w, guid)
        elseif n then
          let offset = Rand.i32_between(-(w / 2), -1)
          tiles = try_room(tiles, pos, pos + Directions.up(),
            Pos(offset, -(h - 1)), h, w, guid)
        end
      end
      consume tiles
    end

  fun tag is_blocked(tiles: Tiles, pos: Pos val): Bool =>
    (exists_and_is_blocked(tiles, pos + Directions.up())
      and exists_and_is_blocked(tiles, pos + Directions.left()))
    or (exists_and_is_blocked(tiles, pos + Directions.up())
      and exists_and_is_blocked(tiles, pos + Directions.right()))
    or (exists_and_is_blocked(tiles, pos + Directions.down())
      and exists_and_is_blocked(tiles, pos + Directions.left()))
    or (exists_and_is_blocked(tiles, pos + Directions.down())
      and exists_and_is_blocked(tiles, pos + Directions.right()))

  fun tag exists_and_is_blocked(tiles: Tiles, pos: Pos val): Bool =>
    try
      (not tiles(pos)?.is_passable()) and (not tiles(pos)?.is_diggable())
    else
      true
    end

  fun tag try_room(tiles: Tiles, door: Pos val, connector: Pos val,
    offset: Pos val, h: I32, w: I32, guid: U128): Tiles
  =>
    let top_left = connector + offset
    let scan = Scan(top_left, h, w)
    // Check for free space
    try
      for p in scan() do
        if not tiles(p)?.is_diggable() then return tiles end
      end
      let next_shape = RectRoom(top_left, Pos(top_left.x + (w - 1),
        top_left.y + (h - 1)))
      tiles.add_room(guid, next_shape)
      for p in next_shape.perimeter() do
        try tiles(p)? =
          recover
            Tile(EmptyOccupant, OccupantCodes.none(), Wall, -1
              where r_id = guid)
          end
        end
      end
      for p in next_shape.interior() do
        try tiles(p)? =
          recover
            Tile(EmptyOccupant, OccupantCodes.none(), Floor, -1
              where r_id = guid)
          end
        end
      end
      tiles(connector)? = Tile(EmptyOccupant, OccupantCodes.none(), Floor, -1
        where r_id = guid)

      let last_r_id = tiles(door)?.room_id
      tiles(door)? = Tile(EmptyOccupant, OccupantCodes.none(), Floor, -1
        where r_id = last_r_id)
    end
    tiles

  fun tag add_downstairs(ts: Tiles iso): Tiles iso^ =>
    recover
      let tiles: Tiles = consume ts
      let room_count = tiles.room_count()
      let room_idx = Rand.usize_between(0, room_count - 1)
      try
        let room = tiles.room(room_idx)?
        let pos = room.rand_interior_position()
        tiles(pos)?.update_landmark(DownStairs(DungeonBuilder))
      end
      tiles
    end
