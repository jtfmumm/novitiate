use "../datast"
use "../rand"

primitive Directions
  fun down(): Pos val => Pos(0, 1)
  fun up(): Pos val => Pos(0, -1)
  fun left(): Pos val => Pos(-1, 0)
  fun right(): Pos val => Pos(1, 0)

  fun rand_cardinal(): Pos val =>
    let roll = Rand.i32_between(0, 3)
    match roll
    | 0 => left()
    | 1 => right()
    | 2 => up()
    | 3 => down()
    else
      Pos(0, 0)
    end
