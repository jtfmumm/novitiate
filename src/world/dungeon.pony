use "collections"
use "random"
use "time"
use "../agents"
use "../datast"
use "../display"
use "../encounters"
use "../game"
use "../generators"
use "../guid"
use "../inventory"
use "../log"

actor Dungeon is World
  let _parent_world: World tag
  // TODO: Use determinate seed
  let _guid_gen: GuidGenerator = GuidGenerator
  let _display: Display tag
  let _diameter: I32
  let _tiles: Tiles
  let _agents: Agents
  let _turn_manager: TurnManager tag
  let _depth: I32
  var _last_focus: Pos val
  var _present: Bool = false
  var _last_turn: I32 = 0

  new create(d: I32, t_manager: TurnManager tag, display': Display tag,
    depth': I32 = 1, parent': World tag = EmptyWorld,
    self: (Self | None) = None)
  =>
    _diameter = d
    _turn_manager = t_manager
    _parent_world = parent'
    _depth = depth'
    let starting_pos = Pos(_diameter / 2, _diameter / 2)
    _last_focus = starting_pos
    let ts: Tiles iso = Digout(d, starting_pos, _depth)
    _display = display'
    _agents = Agents(_display)
    _tiles = PerRoomInitialPlacements(consume ts, _depth, _display)

    try
      let s = self as Self
      PerRoomAgentPlacements(_tiles, this, _turn_manager, _depth, s)
    else
      PerRoomAgentPlacements(_tiles, this, _turn_manager, _depth)
    end

    if _depth > 1 then
      try _tiles(starting_pos)?.update_landmark(UpStairs) end
    end

  be increment_turn() => _last_turn = _last_turn + 1

  be enter(self: Self) =>
    add_agent(self, _last_focus, OccupantCodes.self())
    self.update_world(this)
    self.enter_world_at(_last_focus, _depth)
    _display.log("Entering depth " + _depth.string())
    _present = true

  fun ref _exit(pos: Pos val, self: Self) =>
    _last_focus = pos
    remove_occupant(pos)
    agents().remove(self)
    _present = false

  be add_agent(a: Agent tag, pos: Pos val, occupant_code: I32) =>
    _agents.add(a)
    set_occupant(pos, a, occupant_code)

  fun display(): Display tag => _display

  fun diameter(): I32 => _diameter

  fun ref tile(pos: Pos val): Tile =>
    try
      _tiles(pos)?
    else
      Tile.empty()
    end

  fun ref tiles(): Tiles => _tiles

  fun ref agents(): Agents => _agents

  fun depth(): I32 => _depth

  fun parent(): World tag => _parent_world

  fun turn_manager(): (TurnManager | None) => _turn_manager

  fun present(): Bool => _present

