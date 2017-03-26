use "collections"
use "../../datast"
use "../../rand"
use "../../world"

primitive ChaseLineOfSightMovementAi
  fun apply(tiles: Tiles, rand: Rand, abs_self_pos: Pos val,
    scan_close: ScanClose): Pos val
  =>
    let self_pos = tiles.relative_pos_for(abs_self_pos)
    let mid = Pos(tiles.w() / 2, tiles.h() / 2)
    for pos in scan_close(self_pos) do
      let line = LineIterator(mid, pos)
      for p in line do
        try
          let t = tiles(p)
          if t.is_transparent() then
            if t.is_self() then
              let dx: I32 =
                if p.x < mid.x then -1
                elseif p.x > mid.x then 1
                else 0 end
              let dy: I32 =
                if p.y < mid.y then -1
                elseif p.y > mid.y then 1
                else 0 end
              match (dx, dy)
              | (_, 0) => return Pos(dx, dy)
              | (0, _) => return Pos(dx, dy)
              else
                if rand.flip() == 0 then return Pos(dx, 0)
                else return Pos(0, dy) end
              end
            end
          else
            continue
          end
        end
      end
    end
    Directions.rand_cardinal()
