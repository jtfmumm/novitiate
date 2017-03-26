use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor CloakedShadow is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.cloaked_shadow(),
        movement_ai' = ChaseLineOfSightMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "cloaked shadow",
        description' = "a shadowy figure wrapped in a cloak",
        vision' = 30,
        pos' = p,
        ac' = 14,
        hd' = 4,
        dmg' = 6,
        hit_bonus' = 2
      )

  fun ref data(): AgentData => _data
