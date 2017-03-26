use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor Mantis is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.mantis(),
        movement_ai' = ChaseLineOfSightMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "mantis",
        description' = "a gigantic mantis",
        vision' = 30,
        pos' = p,
        ac' = 17,
        hd' = 5,
        dmg' = 10,
        hit_bonus' = 3
      )

  fun ref data(): AgentData => _data
