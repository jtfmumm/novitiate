use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../game"
use "../rand"
use "../world"

actor Hellhound is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.hellhound(),
        movement_ai' = ChaseLineOfSightMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "hellhound",
        description' = "a fiery hound with relentless red eyes",
        vision' = 30,
        pos' = p,
        ac' = 16,
        hd' = 4,
        dmg' = 10,
        hit_bonus' = 2
      )

  fun ref data(): AgentData => _data
