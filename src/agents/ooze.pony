use "../ai/combat"
use "../ai/movement"
use "../ai/strategy"
use "../datast"
use "../display"
use "../game"
use "../rand"
use "../world"

actor Ooze is Agent
  embed _data: AgentData

  new create(p: Pos val, w: World tag, t_manager: TurnManager tag) =>
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.ooze(),
        movement_ai' = RandomMovementAi,
        combat_ai' = AdjacentAttackCombatAi,
        find_next_ai' = OozeFindNext,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = w,
        name' = "weird ooze",
        description' = "a weird ooze spread out across the floor",
        vision' = 10,
        pos' = p,
        ac' = 0,
        hd' = 1,
        dmg' = 2,
        hp' = 1,
        xp_gained' = 2
      )

  fun ref data(): AgentData => _data

class OozeFindNext
  let _scan_close: ScanClose = ScanClose(Pos(0, 0))

  fun ref apply(tiles: Tiles, data: AgentData, self_pos: Pos val,
    display: Display tag): {()}
  =>
    let combat_choice = data.combat_ai()(tiles, data.rand())
    if combat_choice.should_attack then
      try
        let target = tiles(combat_choice.target)?.occupant
        let hit_roll = data.rand().i32_between(1, 20) + data.hit_bonus()
        let d = data.rand().i32_between(1, data.damage())
        {()(target, display, hit_roll, d, data) =>
            target.hit(hit_roll, d, data.agent(), data.name(), display)}
      else
        EmptyAct
      end
    else
      (let replicate_target, let should_replicate) = ReplicateAi(tiles,
        data.rand())
      if should_replicate and (data.rand().i32_between(1, 18) == 18) then
        {()(data, replicate_target) =>
          let new_ooze = Ooze(replicate_target, data.world(),
            data.turn_manager())
          data.world().add_agent_if_empty(new_ooze, replicate_target,
            OccupantCodes.ooze())
          data.turn_manager().ack()}
      else
        let move_target = data.movement_ai()(tiles, data.rand(), self_pos,
          _scan_close(self_pos))
        {()(move_target, data) =>
          data.move(move_target)
          data.turn_manager().ack()}
      end
    end


