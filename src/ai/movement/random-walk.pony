use "collections"
use "../../datast"
use "../../rand"
use "../../world"

primitive RandomMovementAi
  fun apply(tiles: Tiles, rand: Rand, self_pos: Pos val,
    scan_close: ScanClose): Pos val
  =>
    Directions.rand_cardinal()
