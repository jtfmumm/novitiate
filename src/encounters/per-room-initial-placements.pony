use "../agents"
use "../game"
use "../datast"
use "../world"
use "../rand"
use "../inventory"
use "collections"
use "../display"

primitive PerRoomInitialPlacements
  fun apply(ts: Tiles iso, depth: I32, d: Display tag,
    max_depth: I32 = 12, r: Rand iso = recover Rand end): Tiles iso^
  =>
    recover
      let tiles: Tiles = consume ts
      let rand: Rand = consume r
      let room_count = tiles.room_count()
      let item_count = room_count / 3
      for i in Range(0, item_count) do
        let room_idx = Rand.usize_between(0, room_count - 1)
        try
          let room = tiles.room(room_idx)?
          let pos = room.rand_interior_position()
          let item: Item val = generate_item(depth, rand)
          tiles(pos)?.set_item(item)
        end
      end
      if depth == max_depth then
        let room_idx = Rand.usize_between(0, room_count - 1)
        try
          let room = tiles.room(room_idx)?
          let pos = room.rand_interior_position()
          tiles(pos)?.set_item(StaffOfEternity)
        end
      end
      tiles
    end

  fun generate_item(depth: I32, rand: Rand): Item val =>
    let roll = rand.i32_between(1, 5)
    try
      match roll
      | 1 =>
        let heal = rand.i32_between(1, (depth + 1) * 3)
        PotionBuilder(heal)
      | 2 => _choose_misc_item(rand)
      | 3 => GoldBuilder(rand.i32_between(1, 20))
      | 4 =>
        let weapon_range = WeaponDepths(depth)
        let max_dmg = WeaponDepths.max_damage(depth)
        let potential_bonus = WeaponDepths.potential_bonus(depth)
        let bonus: I32 = rand.i32_between(0, potential_bonus)
        let choice = rand.usize_between(0, weapon_range.size() - 1)
        var weapon = (weapon_range(choice)?()) as Weapon val
        if (weapon.dmg() + bonus) > max_dmg then
          weapon
        else
          weapon.enhance(bonus)
        end
      | 5 =>
        let armor_range = ArmorDepths(depth)
        let max_ac = ArmorDepths.max_ac(depth)
        let potential_bonus = ArmorDepths.potential_bonus(depth)
        let bonus: I32 = rand.i32_between(0, potential_bonus)
        let choice = rand.usize_between(0, armor_range.size() - 1)
        var armor = (armor_range(choice)?()) as Armor val
        if (armor.ac() + bonus) > max_ac then
          armor
        else
          armor.enhance(bonus)
        end
      else
        _choose_misc_item(rand)
      end
    else
      JarBuilder()
    end

  fun _choose_misc_item(rand: Rand): Item val =>
    match rand.i32_between(1, 7)
    | 1 => JarBuilder()
    | 2 => BottleBuilder()
    | 3 => BookBuilder()
    | 4 => StringBuilder()
    | 5 => CardsBuilder()
    | 6 => SoapBuilder()
    | 7 => BrassBellBuilder()
    else
      JarBuilder()
    end

primitive WeaponDepths
  fun apply(depth: I32): RangedArray[ItemBuilder val] =>
    if depth == 1 then
      WeaponLevels(1)
    elseif depth == 2 then
      WeaponLevels(2)
    elseif depth < 5 then
      WeaponLevels(3)
    elseif depth < 7 then
      WeaponLevels(4)
    else
      WeaponLevels(5)
    end

  fun max_damage(depth: I32): I32 =>
    depth + 5

  fun potential_bonus(depth: I32): I32 =>
    if depth > 8 then
      3
    elseif depth > 5 then
      2
    elseif depth > 2 then
      1
    else
      0
    end

primitive WeaponLevels
  fun apply(level: I32): RangedArray[ItemBuilder val] =>
    match level
    | 1 =>
      // 1d4
      let r = RangedArray[ItemBuilder val]
      r.add(ClubBuilder, 1)
      r.add(DaggerBuilder, 1)
      r.add(SilverDaggerBuilder, 1)
      r
    | 2 =>
      // 1d6
      let r = WeaponLevels(1)
      r.add(QuarterstaffBuilder, 2)
      r.add(HandAxeBuilder, 2)
      r.add(ShortSwordBuilder, 2)
      r.add(LightHammerBuilder, 2)
      r
    | 3 =>
      // 1d8
      let r = WeaponLevels(2)
      r.add(MaceBuilder, 4)
      r.add(BattleAxeBuilder, 4)
      r.add(LongSwordBuilder, 4)
      r.add(WarhammerBuilder, 4)
      r
    | 4 =>
      // 1d10
      let r = WeaponLevels(3)
      r.add(GreatAxeBuilder, 16)
      r.add(BroadSwordBuilder, 16)
      r
    | 5 =>
      let r = WeaponLevels(4)
      r.add(MaceBuilder, 4)
      r.add(BattleAxeBuilder, 4)
      r.add(LongSwordBuilder, 4)
      r.add(WarhammerBuilder, 4)
      r
    else
      RangedArray[ItemBuilder val]
    end

primitive ArmorDepths
  fun apply(depth: I32): RangedArray[ItemBuilder val] =>
    if depth == 1 then
      ArmorLevels(2)
    elseif depth < 3 then
      ArmorLevels(3)
    elseif depth < 5 then
      ArmorLevels(4)
    elseif depth < 6 then
      ArmorLevels(5)
    else
      ArmorLevels(6)
    end

  fun max_ac(depth: I32): I32 =>
    match depth
    | 1 => 3
    | 2 => 4
    | 3 => 4
    | 4 => 5
    | 5 => 5
    | 6 => 6
    | 7 => 7
    | 8 => 7
    | 9 => 8
    | 10 => 8
    | 11 => 9
    | 12 => 9
    else
      10
    end

  fun potential_bonus(depth: I32): I32 =>
    if depth > 8 then
      3
    elseif depth > 5 then
      2
    elseif depth > 2 then
      1
    else
      0
    end

primitive ArmorLevels
  fun apply(level: I32): RangedArray[ItemBuilder val] =>
    match level
    | 1 =>
      let r = RangedArray[ItemBuilder val]
      r.add(LeatherArmorBuilder, 1)
      r
    | 2 =>
      let r = ArmorLevels(1)
      r.add(RingMailBuilder, 1)
      r.add(BucklerBuilder, 1)
      r
    | 3 =>
      let r = ArmorLevels(2)
      r.add(ScaleMailBuilder, 3)
      r.add(BucklerBuilder, 1)
      r
    | 4 =>
      let r = ArmorLevels(3)
      r.add(ChainMailBuilder, 6)
      r.add(BucklerBuilder, 1)
      r
    | 5 =>
      let r = ArmorLevels(4)
      r.add(GreatShieldBuilder, 2)
      r
    | 6 =>
      let r = ArmorLevels(5)
      r.add(PlateMailBuilder, 8)
      r.add(GreatShieldBuilder, 2)
      r
    else
      RangedArray[ItemBuilder val]
    end



