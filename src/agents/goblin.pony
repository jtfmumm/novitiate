use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor Goblin is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.goblin(),
        movement_ai' = ChaseLineOfSightMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "goblin",
        description' = "a goblin",
        vision' = 30,
        pos' = p,
        ac' = 10,
        hd' = 1,
        dmg' = 4,
        hit_bonus' = -2
      )

  fun ref data(): AgentData => _data
