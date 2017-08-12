class Iterators[V: Any val] is Iterator[V]
  let _iters: Array[Iterator[V]]
  var _idx: USize = 0

  new create(iters: Array[Iterator[V]]) =>
    _iters = iters

  fun ref has_next(): Bool => 
    try
      while (_idx < _iters.size()) do
        if _iters(_idx)?.has_next() then return true end
        _idx = _idx + 1
      end
      false
    else
      false
    end

  fun ref next(): V ? =>
    let n = _iters(_idx)?.next()?
    if not _iters(_idx)?.has_next() then
      _idx = _idx + 1
    end
    consume n
