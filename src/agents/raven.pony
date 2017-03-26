use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor Raven is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.raven(),
        movement_ai' = RandomMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "raven",
        description' = "a raven",
        vision' = 7,
        pos' = p,
        ac' = 7,
        hd' = 1,
        dmg' = 3,
        hit_bonus' = -3,
        hp' = 2,
        xp_gained' = 5
      )

  fun ref data(): AgentData => _data
