use "collections"
use "../agents"
use "../datast"
use "../display"
use "../world"

class Inventory
  let _max_size: USize = 40
  let _armor: Array[Item] = Array[Item]
  let _misc: Array[Item] = Array[Item]
  let _potions: Array[Item] = Array[Item]
  let _weapons: Array[Item] = Array[Item]

  new create() =>
    _armor.push(RingMailBuilder().unfreeze())
    _misc.push(JarBuilder().unfreeze())
    _weapons.push(ShortSwordBuilder().unfreeze())

  fun apply(idx: USize): this->Item ? =>
    let w = _weapons.size()
    let a = _armor.size()
    let p = _potions.size()
    let m = _misc.size()

    if idx < w then
      _weapons(idx)?
    elseif idx < (w + a) then
      _armor(idx - w)?
    elseif idx < (w + a + p) then
      _potions(idx - (w + a))?
    else
      _misc(idx - (w + a + p))?
    end

  fun size(): USize =>
    _armor.size() + _misc.size() + _potions.size() + _weapons.size()

  fun can_add(): Bool => size() < _max_size

  fun weapons_starting_idx(): I32 =>
    0

  fun armor_starting_idx(): I32 =>
    _weapons.size().i32()

  fun potions_starting_idx(): I32 =>
    armor_starting_idx() + _armor.size().i32()

  fun misc_starting_idx(): I32 =>
    potions_starting_idx() + _potions.size().i32()

  fun ref add(item: Item): (I32 | None) =>
    // Return index of new item if it's added
    if can_add() then
      match item
      | let w: Weapon =>
        _weapons.push(w)
        _weapons.size().i32() - 1
      | let a: Armor =>
        _armor.push(a)
        armor_starting_idx() + (_armor.size() - 1).i32()
      | let p: Potion =>
        _potions.push(p)
        potions_starting_idx() + (_potions.size() - 1).i32()
      else
        _misc.push(item)
        misc_starting_idx() + (_misc.size() - 1).i32()
      end
    else
      None
    end

  fun ref remove(idx: USize): (Item | None) =>
    let w = _weapons.size()
    let a = _armor.size()
    let p = _potions.size()
    let m = _misc.size()

    try
      if idx < w then
        let i = _weapons(idx)?
        _weapons.remove(idx, 1)
        return i
      elseif idx < (w + a) then
        let i = _armor(idx - w)?
        _armor.remove(idx - w, 1)
        return i
      elseif idx < (w + a + p) then
        let i = _potions(idx - (w + a))?
        _potions.remove(idx - (w + a), 1)
        return i
      else
        let i = _misc(idx - (w + a + p))?
        _misc.remove(idx - (w + a + p), 1)
        return i
      end
    else
      None
    end

  fun category(idx: USize): String =>
    let w = _weapons.size()
    let a = _armor.size()
    let p = _potions.size()
    let m = _misc.size()

    if idx < w then "Weapons"
    elseif idx < (w + a) then "Armor"
    elseif idx < (w + a + p) then "Potions"
    else "Miscellaneous" end

  fun local_idx(idx: USize): USize =>
    let w = _weapons.size()
    let a = _armor.size()
    let p = _potions.size()
    let m = _misc.size()

    if idx < w then idx
    elseif idx < (w + a) then idx - w
    elseif idx < (w + a + p) then idx - (w + a)
    else idx - (w + a + p) end

  fun displayable(): Map[String, Array[String] val] val =>
    let map: Map[String, Array[String] val] trn =
      recover Map[String, Array[String] val] end
    map("Armor") = _string_array(_armor)
    map("Miscellaneous") = _string_array(_misc)
    map("Potions") = _string_array(_potions)
    map("Weapons") = _string_array(_weapons)
    consume map

  fun _string_array(items: Array[Item] box): Array[String] iso^ =>
    let arr: Array[String] iso = recover Array[String] end
    for item in items.values() do
      arr.push(item.string())
    end
    consume arr

class InventoryManager
  let _inventory: Inventory
  let _self: Self tag
  let _agent_data: AgentData
  let _display: Display tag
  var _current: I32 = 0
  var _weapon: (Weapon | None) = None
  var _armor: (Armor | None) = None
  var _helmet: (Armor | None) = None
  var _shield: (Armor | None) = None
  //One slot for each of [weapon, armor, helmet, shield]
  //-1 if nothing is equipped
  let _equipped: Array[I32] = Array[I32]

  new create(inventory: Inventory, self: Self tag, agent_data: AgentData,
    display: Display tag) =>
    _inventory = inventory
    _self = self
    _agent_data = agent_data
    _display = display
    _equipped.push(-1)
    _equipped.push(-1)
    _equipped.push(-1)
    _equipped.push(-1)
    _init()

  fun ref _init() =>
    equip(); next(); equip()
    _current = 0

  fun ref next() =>
    _current = (_current + 1) % _inventory.size().i32()

  fun ref prev() =>
    _current = _current - 1
    if _current < 0 then _current = (_inventory.size() - 1).i32() end

  fun ref reset_current() => _current = 0

  fun description(): String =>
    try
      _inventory(_current.usize())?.description()
    else
      "nothing"
    end

  fun ref drop(w: World tag, pos: Pos val) =>
    let item = _remove_and_unequip()
    match item
    | let i: Item =>
      w.try_add_item(i.freeze(), pos)
    end

  fun ref destroy() =>
    _remove_and_unequip()

  fun ref _remove_and_unequip(): (Item | None) =>
    let item = _inventory.remove(_current.usize())
    match item
    | let i: Item =>
      _unequip(i)
      for (idx, v) in _equipped.pairs() do
        try
          if v == _current then
            _equipped(idx)? = -1
          elseif v > _current then
            _equipped(idx)? = v - 1
          end
        end
      end
      if _current.usize() >= _inventory.size() then _current = _current - 1 end
      if _current < 0 then _current = 0 end
      i
    else
      None
    end

  fun ref add(item: Item val): Bool =>
    match item
    | let s: StaffOfEternity val =>
      _display.log("You have found the Staff of Eternity!")
      _self.win_game()
      true
    | let gp: Gold val =>
      _agent_data.modify_gp(gp.amount())
      true
    else
      match _inventory.add(item.unfreeze())
      | let idx: I32 =>
        for (i, v) in _equipped.pairs() do
          try
            if v >= idx then
              _equipped(i)? = v + 1
            end
          end
        end
        true
      else
        false
      end
    end

  fun ref try_item() =>
    try
      let item = _inventory(_current.usize())?
      match item
      | let w: Weapon => equip()
      | let a: Armor => equip()
      | let p: Potion => utilize()
      | let mi: MiscItem => mi.try_to_use(_display)
      else
        _display.log("You don't know what to do with the " + item.name())
      end
    else
      _display.log("<<Error finding item>>")
    end

  fun ref utilize() =>
    try
      let item = _inventory(_current.usize())?
      match item
      | let p: Potion =>
        p.drink(_self, _display)
        destroy()
      | let mi: MiscItem => mi.try_to_use(_display)
      else
        _display.log("You don't know what to do with the " + item.name())
      end
    else
      _display.log("<<Error finding item>>")
    end

  fun ref equip() =>
    try
      let item = _inventory(_current.usize())?
      match item
      | let w: Weapon => equip_weapon(w)
      | let a: Armor => equip_armor(a)
      else
        _display.log("The " + item.name() + " cannot be equipped.")
      end
    else
      _display.log("<<Error finding item>>")
    end

  fun ref _unequip(i: Item) =>
    match i
    | let w: Weapon => unequip_weapon(w)
    | let a: Armor => unequip_armor(a)
    end

  fun ref equip_weapon(w: Weapon) =>
    try
      let old_w = _weapon as Weapon
      _agent_data.modify_hit_bonus(-old_w.bonus())
    end
    _weapon = w
    _agent_data.update_dmg(w.dmg())
    _agent_data.update_dmg_bonus(w.bonus())
    _agent_data.modify_hit_bonus(w.bonus())
    try _equipped(0)? = _current end

  fun ref equip_armor(a: Armor) =>
    match a.armor_type()
    | BodyArmor =>
      match _armor
      | let ar: Armor =>
        _agent_data.modify_ac(-ar.ac())
      end
      _armor = a
      _agent_data.modify_ac(a.ac())
      try _equipped(1)? = _current end
    | Helmet =>
      match _helmet
      | let ar: Armor =>
        _agent_data.modify_ac(-ar.ac())
      end
      _helmet = a
      _agent_data.modify_ac(a.ac())
      try _equipped(2)? = _current end
    | Shield =>
      match _shield
      | let ar: Armor =>
        _agent_data.modify_ac(-ar.ac())
      end
      _shield = a
      _agent_data.modify_ac(a.ac())
      try _equipped(3)? = _current end
    end

  fun ref unequip_weapon(w: Weapon) =>
    try
      if _equipped(0)? == _current then
        _agent_data.modify_hit_bonus(-w.bonus())
        _agent_data.update_dmg(1)
        _agent_data.update_dmg_bonus(0)
        _equipped(0)? = -1
      end
    end

  fun ref unequip_armor(a: Armor) =>
    try
      match a.armor_type()
      | BodyArmor =>
        if _equipped(1)? == _current then
          match _armor
          | let ar: Armor =>
            _agent_data.modify_ac(-ar.ac())
          end
          try _equipped(1)? = -1 end
        end
      | Helmet =>
        if _equipped(2)? == _current then
          match _helmet
          | let ar: Armor =>
            _agent_data.modify_ac(-ar.ac())
          end
          try _equipped(2)? = -1 end
        end
      | Shield =>
        if _equipped(3)? == _current then
          match _shield
          | let ar: Armor =>
            _agent_data.modify_ac(-ar.ac())
            try _equipped(3)? = -1 end
          end
        end
      end
    end

  fun displayable(): InventoryDisplayable val =>
    let equipped: Map[String, Array[USize] val] trn =
      recover Map[String, Array[USize] val] end
    equipped("Armor") = _equipped_list_armor()
    equipped("Weapons") = _equipped_list_weapons()
    let highlighted = (_inventory.category(_current.usize()),
      _inventory.local_idx(_current.usize()))
    InventoryDisplayable(highlighted, _inventory.displayable(),
      consume equipped)

  fun _equipped_list_armor(): Array[USize] val =>
    let list: Array[USize] iso = recover Array[USize] end
    try
      for (idx, v) in _equipped.pairs() do
        if (idx > 0) and (idx < 4) and (v != -1) then
          list.push(_inventory.local_idx(_equipped(idx)?.usize()))
        end
      end
    end
    consume list

  fun _equipped_list_weapons(): Array[USize] val =>
    let list: Array[USize] iso = recover Array[USize] end
    try
      if _equipped(0)? != -1 then
        list.push(_inventory.local_idx(_equipped(0)?.usize()))
      end
    end
    consume list


class InventoryDisplayable
  let highlighted: (String, USize)
  let items: Map[String, Array[String] val] val
  let equipped: Map[String, Array[USize] val] val

  new val create(highlighted': (String, USize),
    items': Map[String, Array[String] val] val,
    equipped': Map[String, Array[USize] val] val) =>
    highlighted = highlighted'
    items = items'
    equipped = equipped'
