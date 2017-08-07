class MinHeap[V: (Comparable[V] #read & Any #alias)]
  let _data: Array[V]

  new create(len: USize = 0) =>
    _data = Array[V](len)

  fun ref _left_child_idx(idx: USize): USize =>
    ((idx + 1) * 2) - 1

  fun ref _right_child_idx(idx: USize): USize =>
    ((idx + 1) * 2)

  fun ref _parent_idx(idx: USize): USize =>
    ((idx + 1) / 2) - 1

  fun ref _bubble_up(idx: USize) =>
    if idx == 0 then return end
    try
      let el = _data(idx)?   
      let parent_idx = _parent_idx(idx)
      let parent = _data(parent_idx)?
      if el < parent then
        _data(idx)? = parent
        _data(parent_idx)? = el
        _bubble_up(parent_idx)
      end
    end

  fun ref _bubble_down(idx: USize) =>
    if idx >= (_data.size() - 1) then return end
    let left_idx = _left_child_idx(idx)
    let right_idx = _right_child_idx(idx)
    if left_idx >= _data.size() then return end
    try
      let el = _data(idx)?
      if right_idx >= _data.size() then
        let left = _data(left_idx)?
        if left < el then
          _data(idx)? = left
          _data(left_idx)? = el
        end
      else
        let left = _data(left_idx)?
        let right = _data(right_idx)?
        if left < right then
          if left < el then
            _data(idx)? = left
            _data(left_idx)? = el
            _bubble_down(left_idx)
          end
        else
          if right < el then
            _data(idx)? = right
            _data(right_idx)? = el
            _bubble_down(right_idx)
          end
        end
      end       
    end

  fun ref insert(v: V) =>
    _data.push(v)
    _bubble_up(_data.size() - 1)

  fun ref pop(): V ? =>
    let el = _data(0)?
    if _data.size() > 1 then
      _data(0)? = _data.pop()?
      _bubble_down(0)
    else
      _data.pop()?
    end
    el

  fun peek(): this->V ? => _data(0)?

  fun size(): USize => _data.size()
