use "collections"
use "time"
use "../agents"
use "../datast"
use "../display"
use "../world"

actor TurnManager
  var pending_turn: (World tag | None) = None
  var last_rank_acted: I32 = -1
  var current_expected_acks: USize = 0
  var acks_left: USize = 0
  var ready_map: Map[USize, Agent tag] = Map[USize, Agent tag]
  let game: Game
  let display: Display tag
  var looping: Bool = false
  var stopped: Bool = false
  // Current position of Self
  var self_pos: Pos val = Pos(-1, -1)

  new create(g: Game, d: Display tag) =>
    game = g
    display = d

  be clear() =>
    acks_left = 0
    looping = false

  be next_turn(w: World tag, sp: Pos val) =>
    self_pos = sp
    pending_turn = w
    _start_next()

  be loop_next_turn(w: World tag, sp: Pos val) =>
    looping = true
    next_turn(w, self_pos)

  be stop_loop(self: Self tag) =>
    looping = false
    _end_turn()

  fun ref _start_next() =>
    try
      (pending_turn as World tag).next_turn(this, self_pos)
      game.increment_turn()
    end

  be set_expected_acks(expected: USize) =>
    current_expected_acks = expected
    acks_left = expected

  be ack_ready(rank: USize, agent: Agent tag) =>
    ready_map(rank) = agent
    if (rank.i32() - last_rank_acted) == 1 then
      last_rank_acted = rank.i32()
      agent.act()
      try
        while ready_map.contains(last_rank_acted.usize() + 1) do
          ready_map(last_rank_acted.usize() + 1)?.act()
          last_rank_acted = last_rank_acted + 1
        end
      end
    end

  be ack() =>
    if not stopped then
      if acks_left > 0 then
        acks_left = acks_left - 1
        if (acks_left == 0) then
          game.display_stats()
          if looping then
            game.loop()
          end
          _end_turn()
        end
      else
        // TODO: This shouldn't happen
        // game.log("!!--!!")
        // game.log("--!!--")
        // game.log("!!--!!")
        None
      end
    end

  fun ref _end_turn() =>
    game.next_turn()
    ready_map.clear()
    last_rank_acted = -1
    game.update_seen()

  be report_death(a: Agent tag, pos: Pos val, w: World tag) =>
    acks_left = acks_left + 1
    w.process_death(a, pos)

  be update_focus(pos: Pos val) =>
    game.update_focus(pos)

  be panic() =>
    // Just in case anything were to go wrong, this can clear, pause,
    // and reset
    if looping then
      game.stop_loop()
    end
    try (pending_turn as World tag).stop_agents() end
    stopped = true
    let timers = Timers
    let timer = Timer(PanicNotify(this), 500_000_000)
    timers(consume timer)

  be recover_from_panic() =>
    acks_left = 0
    try (pending_turn as World tag).restart_agents() end
    game.display_stats()
    _end_turn()
    stopped = false

class PanicNotify is TimerNotify
  let _turn_manager: TurnManager

  new iso create(turn_manager: TurnManager) =>
    _turn_manager = turn_manager

  fun ref apply(timer: Timer, count: U64): Bool =>
    _turn_manager.recover_from_panic()
    false

