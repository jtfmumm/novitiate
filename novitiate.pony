use "options"
use "time"
use "src/game"
use "src/novinput"

actor Main
  new create(env: Env) =>
    let options = Options(env.args)
    let seed = Time.micros()
    var noscreen = false
    var is_overworld = false
    var see_input = false
    var is_simple_dungeon = false
    var enable_fast = false

    options
      .add("overworld", "o", None)
      .add("simple-dungeon", "s", None)
      .add("seekeys", "k", None)
      .add("noscreen", "n", None)
      .add("enable-fast", "f", None)

    for option in options do
      match option
      | ("noscreen", None) =>
        noscreen = true
      | ("overworld", None) =>
        is_overworld = true
      | ("simple-dungeon", None) =>
        is_simple_dungeon = true
      | ("seekeys", None) =>
        see_input = true
      | ("enable-fast", None) =>
        enable_fast = true
      end
    end

    Game(env, seed where noscreen = noscreen,
      is_overworld = is_overworld, is_simple_dungeon = is_simple_dungeon,
      see_input = see_input, enable_fast = enable_fast)
