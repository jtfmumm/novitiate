use "collections"
use "../../datast"
use "../../rand"
use "../../world"

primitive RunMovementAi
  fun apply(tiles: Tiles, rand: Rand, abs_self_pos: Pos val,
    scan_close: ScanClose): Pos val
  =>
    let self_pos = tiles.relative_pos_for(abs_self_pos)
    let x = self_pos.x
    let y = self_pos.y
    let mid = Pos(tiles.w() / 2, tiles.h() / 2)
    if (self_pos >= Pos(0, 0)) or (self_pos < Pos(tiles.w(), tiles.h())) then
      let dx: I32 =
        if x < mid.x then 1
        elseif x > mid.x then -1
        else 0 end
      let dy: I32 =
        if y < mid.y then 1
        elseif y > mid.y then -1
        else 0 end
      match (dx, dy)
      | (_, 0) => return Pos(dx, dy)
      | (0, _) => return Pos(dx, dy)
      else
        if rand.flip() == 0 then return Pos(dx, 0)
        else return Pos(0, dy) end
      end
    end
    Directions.rand_cardinal()
