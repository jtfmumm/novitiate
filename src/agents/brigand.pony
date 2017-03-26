use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor Brigand is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.brigand(),
        movement_ai' = ChaseLineOfSightMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "brigand",
        description' = "a brigand",
        vision' = 30,
        pos' = p,
        ac' = 12,
        hd' = 2,
        dmg' = 6,
        hit_bonus' = -1
      )

  fun ref data(): AgentData => _data
