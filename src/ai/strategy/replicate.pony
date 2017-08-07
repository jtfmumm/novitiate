use "collections"
use "../../datast"
use "../../rand"
use "../../world"

primitive ReplicateAi
  fun apply(tiles: Tiles, rand: Rand): (Pos val, Bool) =>
    let mid = Pos(tiles.w() / 2, tiles.h() / 2)
    if in_range(tiles) then
      try
        if tiles(mid + Directions.up())?.is_open() then
          ((mid + Directions.up()), true)
        elseif tiles(mid + Directions.right())?.is_open() then
          ((mid + Directions.right()), true)
        elseif tiles(mid + Directions.down())?.is_open() then
          ((mid + Directions.down()), true)
        elseif tiles(mid + Directions.left())?.is_open() then
          ((mid + Directions.left()), true)
        else
          (Pos(-1, -1), false)
        end
      else
        (Pos(-1, -1), false)
      end
    else
      (Pos(-1, -1), false)
    end

  fun in_range(tiles: Tiles): Bool =>
    for row in Range(0, tiles.h().usize()) do
      for col in Range(0, tiles.w().usize()) do
        let x = col.i32()
        let y = row.i32()
        try
          if tiles(Pos(x, y))?.is_self() then
            return true
          end
        end
      end
    end
    false
