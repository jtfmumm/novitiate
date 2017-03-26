use "collections"
use "random"
use "time"
use "../agents"
use "../datast"
use "../display"
use "../game"
use "../generators"
use "../inventory"

trait World
  fun ref tile(pos: Pos val): Tile

  fun ref is_valid_target(pos: Pos val): Bool =>
    let target: Tile = tile(pos)
    target.is_passable()

  fun ref remove_occupant(pos: Pos val) =>
    tile(pos).remove_occupant()

  fun ref set_occupant(pos: Pos val, occupant: Occupant tag,
    occupant_code: I32, discovered: Bool = false) =>
    tile(pos).set_occupant(occupant, occupant_code, discovered)

  be enter(self: Self)

  fun ref _exit(pos: Pos val, self: Self)

  be add_agent(a: Agent tag, pos: Pos val, occupant_code: I32)

  be add_agent_if_empty(a: Agent tag, pos: Pos val, occupant_code: I32) =>
    try
      let t = tiles()(pos)
      if t.is_open() then
        add_agent(a, pos, occupant_code)
      end
    end

  be move_occupant(from: Pos val, to: Pos val, occupant: Occupant tag,
    occupant_code: I32) =>
    if is_valid_target(to) then
      remove_occupant(from)
      set_occupant(to, occupant, occupant_code)
      occupant.update_pos(to)
      if occupant_code == OccupantCodes.self() then
        match turn_manager()
        | let tm: TurnManager tag =>
          tm.update_focus(to)
          tm.ack()
        end
        let to_tile = tile(to)
        discover_room(to_tile.room_id)
        discover(to)
      end
    else
      if occupant_code == OccupantCodes.self() then
        match turn_manager()
        | let tm: TurnManager tag =>
          tm.ack()
        end
      end
    end

  be request_submap(radius: I32, agent: Agent tag, focus: Pos val) =>
    let diameter' = (radius * 2) + 1
    agent.deliver_submap(submap(diameter', focus), display())

  be add_room(id: U128, shape: RoomShape val) => tiles().add_room(id, shape)

  be discover_room(id: U128) =>
    if id != 0 then
      tiles().discover_room(id)
    end

  fun diameter(): I32

  fun ref discover(pos: Pos val) => tile(pos).discover()

  fun ref move_agents() => None

  fun ref tiles(): Tiles

  fun ref agents(): Agents

  be stop_agents() => agents().stop()
  be restart_agents() => agents().restart()

  fun depth(): I32

  fun parent(): World tag => EmptyWorld

  fun turn_manager(): (TurnManager | None)

  fun ref submap(diameter': I32, focus: Pos val): Tiles iso^ =>
    let top_left = Pos(focus.x - (diameter' / 2), focus.y - (diameter' / 2))
    tiles().submap(diameter', diameter', top_left)

  fun display(): Display tag

  be increment_turn()

  be display_map(h: I32, w: I32, focus: Pos val, d: Display tag) =>
    if present() then
      let top_left = Pos(focus.x - (w / 2), focus.y - (h / 2))
      let sub = tiles().submap(h, w, top_left)
      d(consume sub)
    end

  be update_seen(h: I32, w: I32, focus: Pos val) =>
    let tlx = focus.x - ((w / 2) + 1)
    let tly = focus.y - ((h / 2) + 1)
    let top_left = Pos(tlx, tly)
    let brx = focus.x + ((w / 2) + 1)
    let bry = focus.y + ((h / 2) + 1)
    let bottom_right = Pos(brx, bry)
    let scan = Scan(top_left, h, w)
    for pos in scan() do
      try tiles()(pos).update_seen(false) end
    end
    let shape = RectRoom(top_left, bottom_right)
    for pos in shape.perimeter() do
      let line = LineIterator(focus, pos)
      for p in line do
        try
          let t = tiles()(p)
          if t.is_transparent() then
            t.update_seen(true)
          else
            t.update_seen(true)
            break
          end
        end
      end
    end

  be next_turn(t_manager: TurnManager tag, self_pos: Pos val) =>
    agents().prepare_act(t_manager, self_pos)

  be highlight(pos: Pos val) =>
    tiles().highlight(pos)

  be unhighlight(pos: Pos val) =>
    tiles().unhighlight(pos)

  be describe(pos: Pos val, d: Display tag) =>
    try
      let t = tiles()(pos)
      if t.is_visible() then
        t.describe(d)
      else
        d.log("You can't see anything.")
      end
    end

  be describe_close(pos: Pos val, d: Display tag) =>
    try
      let t = tiles()(pos)
      if t.is_visible() and t.is_self() then
        t.describe_close(d)
      else
        d.log("You can't see anything.")
      end
    end

  be try_take(pos: Pos val, s: Self tag) =>
    try
      let t = tiles()(pos)
      match t.item
      | let i: Item val =>
        s.pick_up_item(i)
      end
    end

  be remove_item(pos: Pos val) =>
    try
      let t = tiles()(pos)
      t.remove_item()
    end

  be try_add_item(i: Item val, pos: Pos val) =>
    try
      let t = tiles()(pos)
      match t.item
      | let s: StaffOfEternity val => None
      else
        t.set_item(i)
      end
    end

  be climb(pos: Pos val, self: Self tag) =>
    try
      let t = tiles()(pos)
      if t.has_upstairs() then
        _exit(pos, self)
        parent().enter(self)
      else
        display().log("No stairs leading up!")
      end
    end

  be portal(pos: Pos val, self: Self tag) =>
    try
      let t_manager = turn_manager()
      match t_manager
      | let tm: TurnManager tag =>
        let t = tiles()(pos)
        if t.has_downstairs() then
          _exit(pos, self)
          let down = t.portal(diameter(), tm, display(),
            depth() + 1, this)
          down.enter(self)
        else
          display().log("No stairs leading down!")
        end
      end
    end

  be process_death(a: Agent tag, pos: Pos val) =>
    remove_occupant(pos)
    agents().remove(a)
    a.confirm_death()

  fun present(): Bool

actor EmptyWorld is World
  be enter(self: Self) => None
  fun ref _exit(pos: Pos val, self: Self) => None
  fun diameter(): I32 => 0
  fun ref tile(pos: Pos val): Tile => Tile.empty()
  fun ref is_valid_target(pos: Pos val): Bool => false
  fun ref tiles(): Tiles => Tiles(0, 0)
  be add_agent(a: Agent tag, pos: Pos val, occupant_code: I32) => None
  fun ref agents(): Agents => Agents(EmptyDisplay)
  fun turn_manager(): (TurnManager | None) => None
  fun display(): Display tag => EmptyDisplay
  fun depth(): I32 => 0
  be increment_turn() => None
  fun present(): Bool => false
