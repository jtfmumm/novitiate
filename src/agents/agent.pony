use "collections"
use "../datast"
use "../display"
use "../game"
use "../world"

trait Agent
  be act() => data().act()

  be update_world(w: World tag) => data().update_world(w)

  be update_pos(p: Pos val) => data().update_pos(p)

  be prepare_act(turn_rank: USize, self_pos: Pos val) =>
    data().prepare_act(turn_rank, self_pos)

  be deliver_submap(tiles: Tiles iso, display: Display tag) =>
    data().deliver_submap(consume tiles, display)

  be hit(hit_roll: I32, dmg: I32, attacker: Agent tag, attacker_name: String,
    display: Display tag)
  =>
    data().hit(hit_roll, dmg, attacker, attacker_name, display)

  be describe(display: Display tag) => display.log("You see " + description())

  be confirm_death() => data().confirm_death()

  be modify_xp(xp: I32) => None

  be modify_hp(hp: I32, display: Display tag) => data().modify_hp(hp, display)

  fun ref _modify_hp(hp: I32, display: Display tag) => data().modify_hp(hp,
    display)

  fun ref name(): String => data().name()

  fun ref description(): String => data().description()

  fun ref data(): AgentData
