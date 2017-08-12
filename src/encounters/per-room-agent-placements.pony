use "collections"
use "../agents"
use "../datast"
use "../display"
use "../game"
use "../rand"
use "../world"

primitive PerRoomAgentPlacements
  fun apply(tiles: Tiles, world: World tag, turn_manager: TurnManager tag,
    depth: I32, self: (Self | None) = None, r: Rand iso = recover Rand end)
  =>
    let agents: Array[Agent tag] = Array[Agent tag]
    let agent_depths = AgentDepths(depth)
    let rand: Rand = consume r
    let room_count = tiles.room_count()
    let agent_count: USize = room_count / 2
    try
      let s = self as Self
      s.update_next_level_xp(agent_count.i32() * 20)
    end
    for i in Range(0, agent_count) do
      let room_idx = Rand.usize_between(0, room_count - 1)
      try
        let room = tiles.room(room_idx)?
        let pos = room.rand_interior_position()
        let roll = rand.usize_between(0, agent_depths.size() - 1)
        try
          agent_depths(roll)?(pos, world, turn_manager)
        end
      end
    end

primitive AgentDepths
  fun apply(depth: I32):
    RangedArray[{(Pos val, World tag, TurnManager tag)} val]
  =>
    match depth
    | 1 =>
      let r = RangedArray[{(Pos val, World tag, TurnManager tag)} val]
      let f1 = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Raven(p, w, t)}
      let f2 = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Goblin(p, w, t)}
      r.add(f1, 1)
      r.add(f2, 1)
      r
    | 2 =>
      AgentDepths(1)
    | 3 =>
      let r = AgentDepths(2)
      let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Brigand(p, w, t)}
      r.add(f, 2)
      r
    | 4 =>
      let r = AgentDepths(3)
      // let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
      //   Ooze(p, w, t)}
      // r.add(f, 3)
      r
    | 5 =>
      let r = AgentDepths(3)
      let f1 = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Brigand(p, w, t)}
      // let f2 = {(p: Pos val, w: World tag, t: TurnManager tag) =>
      //   Ooze(p, w, t)}
      let f3 = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Skeleton(p, w, t)}
      r.add(f1, 3)
      // r.add(f2, 1)
      r.add(f3, 6)
      r
    | 6 =>
      let r = AgentDepths(5)
      let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Ekek(p, w, t)}
      r.add(f, 6)
      r
    | 7 =>
      let r = AgentDepths(6)
      let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Hellhound(p, w, t)}
      r.add(f, 12)
      r
    | 8 =>
      let r = AgentDepths(7)
      let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        CloakedShadow(p, w, t)}
      r.add(f, 12)
      r
    | 9 =>
      let r = AgentDepths(8)
      let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Mantis(p, w, t)}
      r.add(f, 24)
      r
    | 10 =>
      let r = AgentDepths(9)
      let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Horror(p, w, t)}
      r.add(f, 24)
      r
    | 11 =>
      let r = AgentDepths(10)
      let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Vampire(p, w, t)}
      r.add(f, 48)
      r
    | 12 =>
      let r = AgentDepths(11)
      let f = {(p: Pos val, w: World tag, t: TurnManager tag) =>
        Vampire(p, w, t)}
      r.add(f, 48)
      r
    else
      RangedArray[{(Pos val, World tag, TurnManager tag)} val]
    end
