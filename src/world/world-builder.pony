use "../agents"
use "../datast"
use "../display"
use "../game"

interface WorldBuilder
  fun apply(diameter: I32, turn_manager: TurnManager tag, display: Display tag,
    depth: I32, parent: World tag): World tag

primitive DungeonBuilder
  fun apply(diameter: I32, turn_manager: TurnManager tag, display: Display tag,
    depth: I32 = 1, parent: World tag = EmptyWorld): World tag
  =>
    Dungeon(diameter, turn_manager, display, depth, parent)
