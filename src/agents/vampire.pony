use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor Vampire is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.vampire(),
        movement_ai' = ChaseLineOfSightMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "vampire",
        description' = "a vampire",
        vision' = 30,
        pos' = p,
        ac' = 20,
        hd' = 6,
        dmg' = 12,
        hit_bonus' = 4
      )

  fun ref data(): AgentData => _data
