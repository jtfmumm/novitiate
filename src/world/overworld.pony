// TODO: All this code can be uncommented once I deal with
// match issue in Matrix raised by ponyc changes.

// use "collections"
// use "random"
// use "time"
// use "../agents"
// use "../datast"
// use "../display"
// use "../game"
// use "../generators"
// use "../log"

// actor OverWorld is World
//   let _parent_world: World tag = EmptyWorld
//   let _diameter: I32
//   let _diameter_per_region: I32 = 65
//   let _tiles: Tiles
//   let _agents: Agents
//   let _display: Display tag
//   let _rand: Random
//   let _dice: Dice
//   let _turn_manager: TurnManager tag
//   let _depth: I32 = 0
//   var _last_focus: Pos val = Pos(0, 0)
//   var _last_turn: I32 = 0

//   new create(diameter': I32,
//     t_manager: TurnManager tag, seed: U64, display': Display tag) =>
//     _rand = MT(seed)
//     _dice = Dice(_rand)
//     _diameter = diameter'
//     _tiles = Tiles(_diameter, _diameter)
//     _turn_manager = t_manager
//     _display = display'
//     _agents = Agents(_display)

//     try
//       let terrain = DiamondSquare(_diameter, _diameter_per_region, _rand)?
//       for row in Range(0, _diameter.usize()) do
//         for col in Range(0, _diameter.usize()) do
//           let next_cell = Pos(row.i32(), col.i32())
//           let elevation = terrain(next_cell)?
// //          let elevation: ISize = 2
//           match _dice(1, 3)
//           | 1 => _tiles(next_cell)? =
//             (Tile(EmptyOccupant, OccupantCodes.none(), Plain,
//               elevation.isize()))
//           | 2 => _tiles(next_cell)? =
//             (Tile(EmptyOccupant, OccupantCodes.none(), Forest,
//               elevation.isize()))
//           | 3 => _tiles(next_cell)? =
//             (Tile(EmptyOccupant, OccupantCodes.none(), Hill,
//               elevation.isize()))
//           else
//             _tiles(next_cell)? = (Tile(EmptyOccupant, OccupantCodes.none(),
//               Plain, elevation.isize()))
//           end
//         end
//       end
//     else
//       Logger.err("Can't generate terrain!")
//     end

//   fun present(): Bool => true

//   be increment_turn() => _last_turn = _last_turn + 1

//   be enter(self: Self) =>
//     let initial_pos = Pos(_diameter / 2, _diameter / 2)
//     self.update_pos(initial_pos)
//     add_agent(self, initial_pos, OccupantCodes.self())
//     set_occupant(initial_pos, self, OccupantCodes.self(), true)
//     self.update_world(this)

//   fun ref _exit(pos: Pos val, self: Self) =>
//     _last_focus = pos
//     remove_occupant(pos)
//     agents().remove(self)

//   be add_agent(a: Agent tag, pos: Pos val, occupant_code: I32) =>
//     _agents.add(a)
//     set_occupant(pos, a, occupant_code)

//   fun display(): Display tag => _display

//   fun diameter(): I32 => _diameter

//   fun ref tile(pos: Pos val): Tile =>
//     try
//       _tiles(pos)?
//     else
//       Tile.empty()
//     end

//   fun ref tiles(): Tiles => _tiles

//   fun ref agents(): Agents => _agents

//   fun depth(): I32 => _depth

//   fun parent(): World tag => _parent_world

//   fun turn_manager(): (TurnManager | None) => _turn_manager
