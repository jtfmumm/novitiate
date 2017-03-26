use "../agents"
use "../datast"
use "../display"
use "../game"
use "../inventory"

class Tile
  var occupant: Occupant tag
  var occupant_code: I32
  var item: (Item val | None) = None
  var terrain: Terrain val
  var landmark: Landmark val = EmptyLandmark
  let elevation: ISize
  let room_id: U128
  var lit: Bool
  var _is_discovered: Bool
  var _is_highlighted: Bool
  var _is_seen: Bool
  var _has_been_seen: Bool

  new create(o: Occupant tag, o_code: I32, t: Terrain val,
    e: ISize = -1, i: (Item val | None) = None,
    l: Landmark = EmptyLandmark, discovered: Bool = false, r_id: U128 = 0,
    lit': Bool = true, h: Bool = false, s: Bool = false, has: Bool = false)
  =>
    occupant = o
    occupant_code = o_code
    item = i
    terrain = t
    landmark = l
    elevation = e
    room_id = r_id
    lit = lit'
    _is_discovered = discovered
    _is_highlighted = h
    _is_seen = s
    _has_been_seen = has

  new empty() =>
    occupant = EmptyOccupant
    occupant_code = OccupantCodes.none()
    terrain = Undug
    elevation = -1
    room_id = 0
    lit = false
    _is_discovered = false
    _is_highlighted = false
    _is_seen = false
    _has_been_seen = false

  fun ref set_occupant(o: Occupant tag, o_code: I32, discovered: Bool = false)
  =>
    occupant = o
    occupant_code = o_code
    if discovered then _is_discovered = true end

  fun ref remove_occupant() =>
    occupant = EmptyOccupant
    occupant_code = OccupantCodes.none()

  fun ref set_item(i: Item val) =>
    item = i

  fun ref remove_item(): (Item val | None) =>
    item = None

  fun ref update_landmark(l: Landmark) =>
    landmark = l

  fun ref update_seen(s: Bool) =>
    if s == true then _has_been_seen = true end
    _is_seen = s

  fun describe(display: Display tag) =>
    if (not is_self()) and is_occupied() then
      occupant.describe(display)
    else
      match item
      | let g: Gold val => display.log("You see some gold pieces.")
      | let i: Item val => display.log("You see an item.")
      else
        if has_landmark() then
          display.log("You see " + landmark.description())
        else
          display.log("You see " + terrain.description())
        end
      end
    end

  fun describe_close(display: Display tag) =>
    match item
    | let i: Item val => display.log("You see " + i.description())
    else
      if has_landmark() then
        display.log("You see " + landmark.description())
      else
        display.log("You see " + terrain.description())
      end
    end

  fun ref portal(diameter: I32,
    turn_manager: TurnManager tag, display: Display tag,
    depth: I32, parent: World tag): World tag
  =>
    match landmark
    | let d: DownStairs val =>
      if d.is_initialized() then
        d.world
      else
        landmark = d.build_world(diameter, turn_manager, display, depth,
          parent)
        match landmark
        | let ds: DownStairs val =>
          ds.world
        else
          EmptyWorld
        end
      end
    else
      EmptyWorld
    end

  fun ref discover() =>
    if terrain.is_discoverable() then
      _is_discovered = true
    end

  fun ref highlight() => _is_highlighted = true

  fun ref unhighlight() => _is_highlighted = false

  fun is_discovered(): Bool => _is_discovered

  fun is_occupied(): Bool =>
    not (occupant_code == OccupantCodes.none())

  fun is_interesting(): Bool =>
    (occupant_code != OccupantCodes.none()) or has_item()
      or has_landmark()

  fun is_empty(): Bool =>
    (occupant_code == OccupantCodes.none()) and (not has_item())
      and (not has_landmark()) and is_passable()

  fun is_passable(): Bool =>
    (occupant_code == OccupantCodes.none()) and terrain.is_passable()

  fun is_visible(): Bool => is_discovered() or (_is_seen and lit)

  fun is_seen(): Bool => _is_seen

  fun is_transparent(): Bool => terrain.is_transparent()

  fun is_highlighted(): Bool => _is_highlighted

  fun is_diggable(): Bool =>
    match terrain
    | Undug => true
    else
      false
    end

  fun is_open(): Bool =>
    this.is_passable() and
      (not this.is_occupied())

  fun is_self(): Bool =>
    occupant_code == OccupantCodes.self()

  fun has_item(): Bool =>
    match item
    | let i: Item val => true
    else
      false
    end

  fun has_landmark(): Bool =>
    match landmark
    | EmptyLandmark => false
    else
      true
    end

  fun has_staircase(): Bool =>
    match landmark
    | UpStairs => true
    | let ds: DownStairs val => true
    else
      false
    end

  fun has_upstairs(): Bool =>
    match landmark
    | UpStairs => true
    else
      false
    end

  fun has_downstairs(): Bool =>
    match landmark
    | let ds: DownStairs val => true
    else
      false
    end

  fun is_void(): Bool =>
    match terrain
    | Void => true
    else
      false
    end

  fun has_been_seen(): Bool => _has_been_seen

  fun clone(): Tile iso^ =>
    let o = occupant
    let o_code = occupant_code
    let t = terrain
    let i = item
    let l = landmark
    let e = elevation
    let d = _is_discovered
    let r = room_id
    let lit' = lit
    let h = _is_highlighted
    let s = _is_seen
    let has = _has_been_seen
    recover Tile(o, o_code, t, e, i, l, d, r, lit', h, s, has) end
