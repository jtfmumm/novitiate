use "../agents"
use "../datast"
use "../display"

interface Occupant
  be update_pos(pos: Pos val) => None
  be hit(hit_roll: I32, dmg: I32, attacker: Agent tag, attacker_name: String,
    display: Display tag) => None
  be describe(display: Display tag)

actor EmptyOccupant is Occupant
  be describe(display: Display tag) => None
