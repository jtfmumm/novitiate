use "../../datast"
use "../../rand"
use "../../world"

interface MovementAi
  fun apply(tiles: Tiles, rand: Rand, abs_self_pos: Pos val,
    scan_close: ScanClose): Pos val

class EmptyMovementAi
  fun apply(tiles: Tiles, rand: Rand, abs_self_pos: Pos val,
    scan_close: ScanClose): Pos val
  =>
    Pos(0, 0)
