use "collections"
use "time"
use "../ai/movement"
use "../ai/combat"
use "../ai/strategy"
use "../datast"
use "../display"
use "../game"
use "../guid"
use "../log"
use "../rand"
use "../world"

class Stats
  var hp: I32
  var dmg: I32
  var hit_bonus: I32
  var ac: I32
  var gp: I32
  var xp: I32
  var level: I32
  let max_hp: I32
  let next_level_xp: I32
  let depth: I32
  let turn: I32

  new create(hp': I32, dmg': I32, hit_bonus': I32, ac': I32, gp': I32,
    xp': I32, level': I32, max_hp': I32, next_level_xp': I32, depth': I32,
    turn': I32)
  =>
    hp = hp'
    dmg = dmg'
    hit_bonus = hit_bonus'
    ac = ac'
    gp = gp'
    xp = xp'
    level = level'
    max_hp = max_hp'
    next_level_xp = next_level_xp'
    depth = depth'
    turn = turn'

  fun string(): String =>
    "HP: " + hp.string() + "<" + max_hp.string() + ">" + "  AC: "
      + ac.string() + "  DMG: " + dmg.string() + "  HIT BONUS: "
      + hit_bonus.string() + "  GP: " + gp.string()
      + "\nLEVEL: " + level.string() + "  XP: " + xp.string()
      + "<" + next_level_xp.string() + ">  DEPTH: " + depth.string()
      + "  TURN: " + turn.string()

class AgentData
  let _agent: Agent tag
  // TODO: This should be based on a determinate seed
  let _id: U128 = GuidGenerator()()
  let _code: I32
  let _movement_ai: MovementAi val
  let _combat_ai: CombatAi val
  let _find_next_ai: FindNextAi
  let _turn_manager: TurnManager tag
  let _rand: Rand
  var _world: World tag
  var _turn_rank: USize = 0
  var _next_act: {()} = EmptyAct
  var _dead: Bool = false
  // Last known Self position
  var _self_pos: Pos val = Pos(-1 , -1)

  var _name: String
  var _description: String
  var _vision: I32
  var _pos: Pos val
  var _ac: I32
  var _hp: I32
  var _dmg: I32
  var _dmg_bonus: I32 = 0
  var _hit_bonus: I32
  var _gp: I32 = 0
  // How much xp is gained by defeating this agent
  var _xp_gained: I32

  new create(
    agent': Agent tag,
    code': I32,
    movement_ai': MovementAi val,
    combat_ai': CombatAi val,
    turn_manager': TurnManager tag,
    rand': Rand,
    world': World tag,
    name': String,
    vision': I32,
    pos': Pos val,
    ac': I32,
    hd': I32,
    dmg': I32,
    description': String = "",
    dmg_bonus': I32 = 0,
    hp': I32 = 0,
    xp_gained': I32 = 0,
    hit_bonus': I32 = 0,
    find_next_ai': FindNextAi = BasicFindNextAi
  )
  =>
    _code = code'
    _movement_ai = movement_ai'
    _combat_ai = combat_ai'
    _find_next_ai = find_next_ai'
    _turn_manager = turn_manager'
    _rand = rand'
    _world = world'

    _name = name'
    _description =
      if description' == "" then "a " + _name
      else description' end
    _vision = vision'
    _pos = pos'
    _ac = ac'
    if hp' > 0 then
      _hp = hp'
    else
      _hp = rand'.roll(hd', 6)
    end
    _dmg = dmg'
    _dmg_bonus = dmg_bonus'
    if xp_gained' > 0 then
      _xp_gained = xp_gained'
    else
      let two: F32 = 2
      _xp_gained = two.pow(hd'.f32() - 1).i32() * 10
    end
    _hit_bonus = hit_bonus'
    _agent = agent'
    _world.add_agent(_agent, _pos, _code)

  fun ref prepare_act(turn_rank: USize, self_pos: Pos val) =>
    _world.request_submap(_vision, _agent, _pos)
    _turn_rank = turn_rank
    _self_pos = self_pos

  fun ref deliver_submap(tiles: Tiles iso, display: Display tag) =>
    _next_act = find_next_act(consume tiles, display)
    _turn_manager.ack_ready(_turn_rank, _agent)

  fun move(pos_change: Pos val) =>
    let target = _pos + pos_change
    _world.move_occupant(pos(), target, _agent, _code)

  fun ref update_world(w: World tag) => _world = w

  fun ref update_pos(p: Pos val) => _pos = p

  fun ref take_damage(dmg: I32, attacker: Agent tag, attacker_name: String,
    display: Display tag)
  =>
    _hp = _hp - dmg
    if _hp <= 0 then
      display.log("The " + _name + " is slain by " + attacker_name + "!")
      mark_dead()
      attacker.modify_xp(_xp_gained)
      _turn_manager.report_death(_agent, _pos, _world)
    end
    _turn_manager.ack()

  fun ref mark_dead() =>
    _dead = true

  fun confirm_death() =>
    _turn_manager.ack()

  fun ref find_next_act(tiles: Tiles, display: Display tag): {()} =>
    _find_next_ai(tiles, this, _self_pos, display)

  fun ref act() =>
    _next_act()

  fun ref hit(hit_roll: I32, dmg: I32, attacker: Agent tag,
    attacker_name: String, display: Display tag)
  =>
    if hit_roll > ac() then
      display.log("The " + _name + " takes " + dmg.string() + " damage!")
      take_damage(dmg, attacker, attacker_name, display)
    else
      display.log("The " + attacker_name + " misses the " + _name + "!")
      _turn_manager.ack()
    end

  fun ref update_hp(h: I32) => _hp = h

  fun ref modify_hp(h: I32, display: Display tag) =>
    let new_hp = _hp + h
    _hp = new_hp
    if _hp <= 0 then
      display.log("The " + _name + " is slain!")
      mark_dead()
    end

  fun ref update_dmg(d: I32) => _dmg = d

  fun ref update_dmg_bonus(d: I32) => _dmg_bonus = d

  fun ref modify_ac(a: I32) => _ac = _ac + a

  fun ref modify_gp(g: I32) => _gp = _gp + g

  fun ref modify_hit_bonus(h: I32) => _hit_bonus = _hit_bonus + h

  fun name(): String => _name

  fun description(): String => _description

  fun vision(): I32 => _vision

  fun ref rand(): Rand => _rand

  fun ac(): I32 => _ac

  fun hp(): I32 => _hp

  fun gp(): I32 => _gp

  fun movement_ai(): MovementAi val => _movement_ai

  fun combat_ai(): CombatAi val => _combat_ai

  fun damage(): I32 => _dmg

  fun hit_bonus(): I32 => _hit_bonus

  fun turn_manager(): TurnManager tag => _turn_manager

  fun agent(): Agent tag => _agent

  fun world(): World tag => _world

  fun pos(): Pos val => _pos

  fun code(): I32 => _code

  fun id(): U128 => _id

  fun display_stats(display: Display tag, level: I32, xp: I32, max_hp: I32,
    next_level_xp: I32, depth: I32, turn: I32)
  =>
    display.stats(stats(level, xp, max_hp, next_level_xp, depth, turn))

  fun stats(level: I32, x: I32, max_hp: I32, next_level_xp: I32,
    depth: I32, turn: I32): Stats val
  =>
    let h = _hp
    let d = _dmg
    let hb = _hit_bonus
    let a = _ac
    let g = _gp
    recover
      Stats(h, d, hb, a, g, x, level, max_hp, next_level_xp, depth, turn)
    end
