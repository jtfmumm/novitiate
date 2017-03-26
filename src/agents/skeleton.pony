use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor Skeleton is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.skeleton(),
        movement_ai' = ChaseLineOfSightMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "skeleton",
        description' = "a moving skeleton",
        vision' = 30,
        pos' = p,
        ac' = 14,
        hd' = 3,
        dmg' = 8,
        hit_bonus' = 0
      )

  fun ref data(): AgentData => _data
