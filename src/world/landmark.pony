use "../agents"
use "../datast"
use "../display"
use "../game"

type Landmark is (
  UpStairs val |
  DownStairs val |
  EmptyLandmark val
)

primitive UpStairs
  fun description(): String => "stairs leading up"

class DownStairs
  var world: World tag
  let _world_builder: WorldBuilder val

  new val create(wb: WorldBuilder val,
    world': World tag = EmptyWorld)
  =>
    world = world'
    _world_builder = wb

  fun is_initialized(): Bool =>
    match world
    | let ew: EmptyWorld => false
    else true
    end

  fun build_world(diameter: I32, turn_manager: TurnManager tag,
    display: Display tag, depth: I32, parent: World tag): DownStairs val
  =>
    let w = _world_builder(diameter, turn_manager, display, depth,
      parent)
    DownStairs(_world_builder, w)

  fun description(): String => "stairs leading down"

primitive EmptyLandmark
  fun description(): String => ""
