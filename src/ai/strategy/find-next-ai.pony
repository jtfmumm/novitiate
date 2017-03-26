use "../../agents"
use "../../datast"
use "../../display"
use "../../world"

interface FindNextAi
  fun ref apply(tiles: Tiles, data: AgentData, self_pos: Pos val, display:
    Display tag): {()}

class BasicFindNextAi
  let _scan_close: ScanClose = ScanClose(Pos(0, 0))

  fun ref apply(tiles: Tiles, data: AgentData, self_pos: Pos val, display:
    Display tag): {()}
  =>
    let combat_choice = data.combat_ai()(tiles, data.rand())
    if combat_choice.should_attack then
      try
        let target = tiles(combat_choice.target).occupant
        let hit_roll = data.rand().i32_between(1, 20) + data.hit_bonus()
        let d = data.rand().i32_between(1, data.damage())
        {()(target, display, hit_roll, d, data) =>
          target.hit(hit_roll, d, data.agent(), data.name(), display)}
      else
        EmptyAct
      end
    else
      let move_target = data.movement_ai()(tiles, data.rand(), self_pos,
        _scan_close(self_pos))
      {()(move_target, data) =>
        data.move(move_target)
        data.turn_manager().ack()}
    end
