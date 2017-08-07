use "../../datast"
use "../../rand"
use "../../world"

primitive AdjacentAttackCombatAi
  fun apply(tiles: Tiles, rand: Rand): CombatChoice val =>
    let mid = Pos(tiles.w() / 2, tiles.h() / 2)
    try
      if tiles(mid + Directions.up())?.is_self() then
        CombatChoice(mid + Directions.up(), true)
      elseif tiles(mid + Directions.right())?.is_self() then
        CombatChoice(mid + Directions.right(), true)
      elseif tiles(mid + Directions.down())?.is_self() then
        CombatChoice(mid + Directions.down(), true)
      elseif tiles(mid + Directions.left())?.is_self() then
        CombatChoice(mid + Directions.left(), true)
      else
        CombatChoice(Pos(-1, -1), false)
      end
    else
      CombatChoice(Pos(-1, -1), false)
    end
