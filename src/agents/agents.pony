use "collections"
use "../datast"
use "../display"
use "../game"
use "../rand"

class Agents
  let _data: Array[Agent tag] = Array[Agent tag]
  let _display: Display tag
  let _rand: Rand = Rand
  var _stopped: Bool = false

  new create(d: Display tag) =>
    _display = d

  fun ref add(a: Agent tag) =>
    if not _data.contains(a) then
      _data.push(a)
    end

  fun ref remove(a: Agent tag) =>
    try
      let idx = _data.find(a)
      _data.remove(idx, 1)
    end

  fun ref stop() => _stopped = true
  fun ref restart() => _stopped = false

  fun ref prepare_act(turn_manager: TurnManager tag, self_pos: Pos val) =>
    if not _stopped then
      try _rand.shuffle_array[Agent tag](_data) end
      turn_manager.set_expected_acks(_data.size())
      for (i, agent) in _data.pairs() do
        agent.prepare_act(i, self_pos)
      end
    end
