use "collections"
use "random"
use "time"

class Rand
  let _rand: Random
  let _indices: Array[USize] = Array[USize]

  new create(seed: U64 = Time.micros()) =>
    _rand = MT(seed)

  fun ref flip(): U64 => _rand.int(2)

  fun ref roll(dice: I32, sides: I32): I32 =>
    var result: I32 = 0
    for i in Range[I32](0, dice) do
      result = result + i32_between(1, sides)
    end
    result

  fun ref i32_between(low: I32, high: I32): I32 =>
    let r = (_rand.int((high.u64() + 1) - low.u64()) and 0x0000FFFF).i32()
    let value = r + low
    value

  fun ref usize_between(low: USize, high: USize): USize =>
    let r = (_rand.int((high.u64() + 1) - low.u64()) and 0x0000FFFF).usize()
    let value = r + low
    value

  fun ref shuffle_array[V](a: Array[V]): Array[V] ? =>
    let size = a.size()
    _indices.clear()
    for i in Range(0, size) do
      _indices.push(i)
    end
    for (i, value) in _indices.pairs() do
      let r = usize_between(i + 1, size - 1)
      _indices(i) = _indices(r)
    end
    a.permute(_indices.values())
    a
