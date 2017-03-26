use "collections"
use "debug"

class RangedArray[V: Any #alias]
  let _data: Map[ISize, V] = Map[ISize, V]
  let _ranges: Array[ISize] = Array[ISize]
  var _last_idx: ISize = -1
  var _size: USize = 0

  fun ref add(v: V, count: USize) =>
    let next_idx = _last_idx + count.isize()
    _data(next_idx) = consume v
    _ranges.push(next_idx)
    _last_idx = next_idx
    _size = _size + count

  fun apply(i: USize): this->V ? =>
    let ext_idx = i.isize()
    for idx in _ranges.values() do
      if ext_idx <= idx then return _data(idx) end
    end
    error

  fun ref append(r: RangedArray[V]) =>
    let current_max: ISize = try _ranges(_ranges.size() - 1) else 0 end
    for range in r._ranges.values() do
      try
        let new_range = range + current_max
        _data(new_range) = r._data(range)
        _ranges.push(new_range)
      end
    end

  fun size(): USize => _size
