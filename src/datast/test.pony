use "ponytest"
use "debug"
use "collections"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestRectRoomShape)
    test(_TestRangedArray)

class iso _TestRectRoomShape is UnitTest
  fun name(): String => "datast:RectRoom"

  fun apply(h: TestHelper) ? =>
    let p1: RoomShape val = RectRoom(Pos(2, 2), Pos(4, 5))
    
    let perimeter_ans = [Pos(2, 2); Pos(3, 2); Pos(4, 2); Pos(4, 3); Pos(4, 4)
      Pos(4, 5); Pos(3, 5); Pos(2, 5); Pos(2, 4); Pos(2, 3)]

    for i in Range(0, 10) do
      h.assert_eq[Pos val](p1.perimeter_space(i)?, perimeter_ans(i)?)
    end

class iso _TestRangedArray is UnitTest
  fun name(): String => "datast:RangedArray"

  fun apply(h: TestHelper) ? =>
    let r = RangedArray[String]
    r.add("hi", 3)
    r.add("man", 3)
    r.add("cool", 1)
    r.add("thing", 2)
    r.add("this", 1)
    r.add("is", 144)

    h.assert_eq[String](r(0)?, "hi")
    h.assert_eq[String](r(1)?, "hi")
    h.assert_eq[String](r(2)?, "hi")
    h.assert_eq[String](r(3)?, "man")
    h.assert_eq[String](r(4)?, "man")
    h.assert_eq[String](r(5)?, "man")
    h.assert_eq[String](r(6)?, "cool")
    h.assert_eq[String](r(7)?, "thing")
    h.assert_eq[String](r(8)?, "thing")
    h.assert_eq[String](r(9)?, "this")
    h.assert_eq[String](r(10)?, "is")
    h.assert_eq[String](r(100)?, "is")
