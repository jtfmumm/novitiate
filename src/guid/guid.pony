use "random"
use "time"

class GuidGenerator
  let _rand: Random

  new create(seed: U64 = Time.micros()) =>
    _rand = MT(seed)

  fun ref apply(): U128 =>
    _rand.u128()
