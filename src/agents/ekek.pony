use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor Ekek is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.ekek(),
        movement_ai' = ChaseLineOfSightMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "ekek",
        description' = "a bizarre creature, half human, half bird",
        vision' = 30,
        pos' = p,
        ac' = 11,
        hd' = 3,
        dmg' = 8,
        hit_bonus' = 1
      )

  fun ref data(): AgentData => _data
