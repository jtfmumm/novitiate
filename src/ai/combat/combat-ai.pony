use "../../datast"
use "../../rand"
use "../../world"

interface CombatAi
  fun apply(tiles: Tiles, rand: Rand): CombatChoice val

class EmptyCombatAi
  fun apply(tiles: Tiles, rand: Rand): CombatChoice val =>
    CombatChoice(Pos(0, 0), false)

class CombatChoice
  let target: Pos val
  let should_attack: Bool

  new val create(t: Pos val, sa: Bool) =>
    target = t
    should_attack = sa
