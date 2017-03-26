use "../agents"
use "../display"

trait Item is Equatable[Item]
  fun weight(): I32
  fun cost(): I32
  fun name(): String
  fun description(): String => "a " + name()
  fun string(): String => name()
  fun eq(that: box->Item): Bool => name() == that.name()

  fun freeze(): Item val
  fun unfreeze(): Item

class Gold is Item
  let _amount: I32
  let _weight: I32
  let _cost: I32

  new create(a: I32) =>
    _amount = a
    _weight = _amount
    _cost = _amount

  fun amount(): I32 => _amount
  fun weight(): I32 => _weight
  fun cost(): I32 => _cost
  fun name(): String => _amount.string() + " gold pieces"
  fun description(): String => name()

  fun freeze(): Item val =>
    let amt = _amount
    recover val Gold(amt) end

  fun unfreeze(): Item =>
    Gold(_amount)

class GoldBuilder
  fun apply(amt: I32): Item val =>
    recover val Gold(amt) end

class MiscItem is Item
  let _weight: I32
  let _cost: I32
  let _name: String
  let _description: String
  let _try_to_use_message: String

  new create(n: String, w: I32, c: I32, desc: String = "",
    try_to_use_message: String = "")
  =>
    _weight = w
    _cost = c
    _name = n
    _description = if desc == "" then "a " + _name else desc end
    _try_to_use_message = try_to_use_message

  fun weight(): I32 => _weight
  fun cost(): I32 => _cost
  fun name(): String => _name
  fun description(): String => _description
  fun try_to_use(display: Display tag) =>
    display.log(_try_to_use_message)

  fun freeze(): Item val =>
    let w = _weight
    let c = _cost
    let n = _name
    let d = _description
    let t = _try_to_use_message
    recover MiscItem(n, w, c, d, t) end

  fun unfreeze(): Item =>
    MiscItem(_name, _weight, _cost, _description, _try_to_use_message)

class Potion is Item
  let _heal: I32
  var _empty: Bool

  new create(h: I32, empty: Bool = false) =>
    _heal = h
    _empty = empty

  fun ref drink(self: Self tag, display: Display tag) =>
    if not _empty then
      display.log("You drink the potion!")
      self.drink_potion(_heal)
      self.display_stats()
      _empty = true
    else
      display.log("The potion is empty!")
    end

  fun weight(): I32 => 2
  fun cost(): I32 => 10
  fun name(): String => if _empty then "empty potion" else "potion" end
  fun description(): String =>
    if _empty then "an empty potion" else "a potion" end

  fun freeze(): Item val =>
    let h = _heal
    let e = _empty
    recover Potion(h, e) end

  fun unfreeze(): Item =>
    Potion(_heal, _empty)

class Weapon is Item
  let _weight: I32
  let _cost: I32
  let _base_name: String
  let _base_desc: (String, String)
  let _name: String
  let _dmg: I32
  let _hands: I8
  let _bonus: I32

  new create(n: String, d: I32, h: I8, w: I32, c: I32, b: I32 = 0,
    desc: (String, String) = ("", ""))
  =>
    _weight = w
    _cost = c
    _bonus = b
    _base_name = n
    _base_desc = desc
    _name =
      if _bonus > 0 then n + " +" + _bonus.string() else n end
    _dmg = d
    _hands = h

  fun weight(): I32 => _weight
  fun cost(): I32 => _cost
  fun dmg(): I32 => _dmg
  fun hands(): I8 => _hands
  fun bonus(): I32 => _bonus
  fun name(): String => _name
  fun description(): String =>
    if (_base_desc._1 == "") and (_base_desc._2 == "") then name()
    else _base_desc._1 + " " + name() + " " + _base_desc._2 end

  fun freeze(): Item val =>
    let w = _weight
    let c = _cost
    let n = _base_name
    let d = _dmg
    let h = _hands
    let b = _bonus
    let desc = _base_desc
    recover Weapon(n, d, h, w, c, b, desc) end

  fun unfreeze(): Item =>
    Weapon(_base_name, _dmg, _hands, _weight, _cost, _bonus, _base_desc)

  fun enhance(enhancement: I32): Item val =>
    let w = _weight
    let c = _cost
    let n = _base_name
    let d = _dmg
    let h = _hands
    let b = enhancement
    let desc = _base_desc
    recover Weapon(n, d, h, w, c, b, desc) end

class Armor is Item
  let _weight: I32
  let _cost: I32
  let _base_name: String
  let _base_desc: (String, String)
  let _name: String
  let _ac: I32
  let _bonus: I32
  let _armor_type: ArmorType

  new create(n: String, ac': I32, b: I32, at: ArmorType, w: I32, c: I32,
    desc: (String, String) = ("", "")) =>
    _weight = w
    _cost = c
    _bonus = b
    _base_name = n
    _base_desc = desc
    _name =
      if _bonus > 0 then n + " +" + _bonus.string() else n  end
    _ac = ac'
    _armor_type = at

  fun weight(): I32 => _weight
  fun cost(): I32 => _cost
  fun ac(): I32 => _ac + _bonus
  fun bonus(): I32 => _bonus
  fun armor_type(): ArmorType => _armor_type
  fun name(): String => _name
  fun description(): String =>
    if (_base_desc._1 == "") and (_base_desc._2 == "") then name()
    else _base_desc._1 + " " + name() + " " + _base_desc._2 end

  fun freeze(): Item val =>
    let w = _weight
    let c = _cost
    let n = _base_name
    let d = _base_desc
    let ac' = _ac
    let b = _bonus
    let at = _armor_type
    recover Armor(n, ac', b, at, w, c, d) end

  fun unfreeze(): Item =>
    Armor(_base_name, _ac, _bonus, _armor_type, _weight, _cost, _base_desc)

  fun enhance(enhancement: I32): Item val =>
    let w = _weight
    let c = _cost
    let n = _base_name
    let ac' = _ac
    let b = enhancement
    let at = _armor_type
    let d = _base_desc
    recover Armor(n, ac', b, at, w, c, d) end

type ArmorType is (
  BodyArmor |
  Shield |
  Helmet
)

primitive BodyArmor
primitive Shield
primitive Helmet

interface ItemBuilder
  fun apply(bonus: I32 = 0): Item val

///////////////////
// Armor
///////////////////
primitive PaddedClothArmorBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Armor("Padded Cloth Armor", 1, bonus, BodyArmor, 10, 100) end

primitive LeatherArmorBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Armor("Leather Armor", 2, bonus, BodyArmor, 15, 200) end

primitive RingMailBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Armor("Ring Mail", 3, bonus, BodyArmor, 25, 300) end

primitive ScaleMailBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Armor("Scale Mail", 4, bonus, BodyArmor, 30, 450) end

primitive ChainMailBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Armor("Chain Mail", 5, bonus, BodyArmor, 40, 600) end

primitive PlateMailBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Armor("Plate Mail", 7, bonus, BodyArmor, 50, 3000) end

primitive BucklerBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Armor("Buckler", 1, bonus, Shield, 5, 70
      where desc = ("a", ""))
    end

primitive GreatShieldBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Armor("Great Shield", 2, bonus, Shield, 10, 350
      where desc = ("a", ""))
    end

///////////////////
// Weapons
///////////////////

//4
primitive ClubBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Club", 4, 1, 1, 2, bonus) end

primitive DaggerBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Dagger", 4, 1, 1, 20, bonus) end

primitive SilverDaggerBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Silver Dagger", 4, 1, 1, 250, 1 + bonus) end

//6
primitive QuarterstaffBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Quarterstaff", 6, 1, 4, 20, bonus) end

primitive HandAxeBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Hand Axe", 6, 1, 5, 40, bonus) end

primitive ShortSwordBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Short Sword", 6, 1, 3, 60, bonus) end

primitive LightHammerBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Light Hammer", 6, 1, 5, 40, bonus) end

//8
primitive LongSwordBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Long Sword", 8, 1, 4, 100, bonus) end

primitive BattleAxeBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Battle Axe", 8, 1, 7, 70, bonus) end

primitive WarhammerBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Warhammer", 8, 1, 10, 60, bonus) end

primitive MaceBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Mace", 8, 1, 10, 60, bonus) end

//10
primitive GreatAxeBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Great Axe", 10, 2, 15, 140, bonus) end

primitive BroadSwordBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val Weapon("Broad Sword", 10, 2, 10, 180, bonus) end

///////////////////
// Items
///////////////////
primitive JarBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val MiscItem("Jar", 1, 10, "an ordinary jar",
      "You don't have anything worth storing in there.") end

primitive BottleBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val MiscItem("Bottle", 1, 10, "an empty bottle",
      "There's nothing to drink in there.") end

primitive BookBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val MiscItem("Book", 1, 10, "a mysterious book",
      "You quickly get bored.") end

primitive StringBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val MiscItem("String", 1, 10, "a piece of string",
      "You tie a knot and then untie it.") end

primitive CardsBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val MiscItem("Deck of Cards", 1, 10, "a deck of cards",
      "No time for solitaire.") end

primitive SoapBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val MiscItem("Soap", 1, 10, "a bar of soap",
      "You need water.") end

primitive BrassBellBuilder
  fun apply(bonus: I32 = 0): Item val =>
    recover val MiscItem("Bell", 1, 10, "a small brass bell",
      "Ding.") end

primitive PotionBuilder
  fun apply(heal: I32): Item val =>
    recover val Potion(heal) end

///////////////////
// Victory
///////////////////
class StaffOfEternity is Item
  fun weight(): I32 => 0
  fun cost(): I32 => 0
  fun name(): String => "Staff of Eternity"
  fun description(): String => "the " + name()

  fun freeze(): Item val =>
    recover val StaffOfEternity end

  fun unfreeze(): Item =>
    StaffOfEternity
