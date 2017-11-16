use "../ai/combat"
use "../ai/movement"
use "../datast"
use "../display"
use "../game"
use "../input"
use "../inventory"
use "../log"
use "../rand"
use "../world"

actor Self is Agent
  embed _data: AgentData
  let _inventory: Inventory = Inventory
  let _inventory_manager: InventoryManager
  let _game: Game tag
  let _display: Display tag
  var _next_command: Cmd val = EmptyCmd
  // reusable ScanClose
  let _scan_close: ScanClose = ScanClose(Pos(0, 0))
  var _next_act: ({()} | None) = None
  var _turn_rank: USize = 0
  var _xp: I32
  var _level: I32
  var _next_level_xp: I32
  var _max_hp: I32 = 20
  var _fast_cmd: Cmd val = EmptyCmd
  var _fast_mode: Bool = false
  var _facing: Pos val = Directions.up()
  var _depth: I32 = 0
  var _turn: I32 = 0

  new create(t_manager: TurnManager tag, display: Display tag,
    game: Game tag, level: I32 = 1, xp: I32 = 0, next_level_xp: I32 = 100) =>
    _display = display
    _game = game
    _level = level
    _xp = xp
    _next_level_xp = next_level_xp
    _data =
      AgentData(where
        agent' = this,
        code' = OccupantCodes.self(),
        movement_ai' = EmptyMovementAi,
        combat_ai' = EmptyCombatAi,
        turn_manager' = t_manager,
        rand' = Rand,
        world' = EmptyWorld,
        name' = "acolyte",
        description' = "our hero",
        vision' = 5,
        pos' = Pos(0, 0),
        ac' = 10,
        hd' = 1,
        hp' = _max_hp,
        dmg' = 1
      )
    _inventory_manager = InventoryManager(_inventory, this, _data, _display)

  be update_next_level_xp(x: I32) => _next_level_xp = x

  fun ref update_depth(depth: I32) => _depth = depth

  be enter_world_at(pos: Pos val, depth: I32) =>
    update_pos(pos)
    update_depth(depth)
    _display_stats()
    _game.update_focus(pos)
    _game.update_world(data().world())

  be enqueue_command(cmd: Cmd val) =>
    _next_command = cmd

  be prepare_act(turn_rank: USize, self_pos: Pos val) =>
    _data.world().request_submap(_data.vision(), this, _data.pos())
    _turn_rank = turn_rank

  be deliver_submap(ts: Tiles iso, display: Display tag) =>
    let tiles: Tiles = consume ts
    if _fast_mode then
      let relative_pos = tiles.relative_pos_for(_data.pos())
      try
        if not tiles(relative_pos + _facing)?.is_passable() then
          _game.exit_fast_mode()
        end
      end
      for pos in _scan_close(relative_pos) do
        try
          if tiles(pos)?.is_interesting() then
            _game.exit_fast_mode()
          end
        end
      end
    end
    find_next_act(tiles)
    _data.turn_manager().ack_ready(_turn_rank, this)

  be hit(hit_roll: I32, dmg: I32, attacker: Agent tag, attacker_name: String,
    display: Display tag)
  =>
    if hit_roll > _data.ac() then
      display.log("The " + attacker_name + " hit you for " + dmg.string()
        + " damage!")
      _data.take_damage(dmg, attacker, attacker_name, display)
    else
      display.log("The " + attacker_name + " misses you!")
      _data.turn_manager().ack()
    end

  be modify_xp(xp: I32) =>
    _xp = _xp + xp
    if _xp >= _next_level_xp then
      level_up()
    end

  be drink_potion(h: I32) =>
    _modify_hp(h, _display)
    _display_stats()

  fun ref level_up() =>
    _level = _level + 1
    _max_hp = _max_hp + 10
    _next_level_xp = _next_level_xp * 2
    _data.update_hp(_max_hp)
    _data.modify_hit_bonus(1)

  fun ref find_next_act(tiles: Tiles) =>
    let cmd =
      if _fast_mode then
        _fast_cmd
      else
        _next_command
      end
    match cmd
    | LeftCmd =>
      _check_move(Directions.left(), tiles)
      _facing = Directions.left()
      ifdef "keys" then _display.log("Left") end
    | RightCmd =>
      _check_move(Directions.right(), tiles)
      _facing = Directions.right()
      ifdef "keys" then _display.log("Right") end
    | UpCmd =>
      _check_move(Directions.up(), tiles)
      _facing = Directions.up()
      ifdef "keys" then _display.log("Up") end
    | DownCmd =>
      _check_move(Directions.down(), tiles)
      _facing = Directions.down()
      ifdef "keys" then _display.log("Down") end
    | TakeCmd =>
      _data.world().try_take(_data.pos(), this)
    | EnterCmd =>
      _data.world().describe_close(_data.pos(), _display)
    | UpStairsCmd =>
      _data.world().climb(_data.pos(), this)
    | DownStairsCmd =>
      _data.world().portal(_data.pos(), this)
    | WaitCmd =>
      _display.log("Wait")
      None
    | EmptyCmd =>
      _data.turn_manager().ack()
    else
      _display.log("Unrecognized Cmd")
    end

  fun ref _check_move(pos_change: Pos val, tiles: Tiles) =>
    let mid = (tiles.w() / 2)
    let mid_pos = Pos(mid, mid)
    let target = mid_pos + pos_change
    try
      if tiles(target)?.is_occupied() then
        try
          let enemy = tiles(target)?.occupant
          let hit_roll = _data.rand().i32_between(1, 20) + _data.hit_bonus()
          let dmg = _data.rand().i32_between(1, _data.damage())
          let that = this
          let name = _data.name()
          let next_act =
            {()(enemy, _display, hit_roll, dmg, that, name) =>
              enemy.hit(hit_roll, dmg, that, name, _display)}
          _next_act = next_act
        else
          _next_act = EmptyAct
        end
      else
        _next_act = build_move(pos_change)
      end
    end

  fun build_move(pos_change: Pos val): {()} =>
    let self: Agent tag = this
    let pos = _data.pos()
    let world = _data.world()
    let code = _data.code()
    {()(pos, world, code, pos_change, self) =>
      let target = pos + pos_change
      world.move_occupant(pos, target, self, code)}

  be act() =>
    match _next_act
    | let na: {()} =>
      na()
      _next_act = None
    else
      _data.turn_manager().ack()
    end

  be pick_up_item(i: Item val) =>
    if _inventory_manager.add(i) then
      _display.log("You take the " + i.name())
      _data.world().remove_item(_data.pos())
    else
      _display.log("There is no space left.\nYou need to drop something.")
    end

  be display_stats() =>
    _display_stats()

  fun ref _display_stats() =>
    _data.display_stats(_display, _level, _xp, _max_hp, _next_level_xp, _depth,
      _turn)

  be process_inventory_command(cmd: Cmd val, display: Display tag) =>
    match cmd
    | LeftCmd =>
      _inventory_manager.prev()
    | RightCmd =>
      _inventory_manager.next()
    | UpCmd =>
      _inventory_manager.prev()
    | DownCmd =>
      _inventory_manager.next()
    | LookCmd =>
      display.log(_inventory_manager.description())
    | EnterCmd =>
      _inventory_manager.try_item()
    | ECmd =>
      _inventory_manager.equip()
    | UCmd =>
      _inventory_manager.utilize()
    | DropCmd =>
      _inventory_manager.drop(_data.world(), _data.pos())
    end
    display.inventory(_inventory_manager.displayable())
    _display_stats()

  be enter_fast_mode(cmd: Cmd val) => _enter_fast_mode(cmd)

  fun ref _enter_fast_mode(cmd: Cmd val) =>
    _fast_cmd = cmd
    match _fast_cmd
    | LeftCmd =>
      _facing = Directions.left()
    | RightCmd =>
      _facing = Directions.right()
    | UpCmd =>
      _facing = Directions.up()
    | DownCmd =>
      _facing = Directions.down()
    end
    _fast_mode = true
    _next_command = EmptyCmd

  be exit_fast_mode() => _exit_fast_mode()

  fun ref _exit_fast_mode() =>
    _fast_cmd = EmptyCmd
    _fast_mode = false

  be exit_inventory_mode() => _inventory_manager.reset_current()

  be clear_commands() =>
    _next_command = EmptyCmd

  be increment_turn() =>
    _turn = _turn + 1

  be win_game() => _game.win()

  fun ref data(): AgentData => _data

