use "collections"
use "debug"
use "ponytest"
use "../datast"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestLineIterator)

class iso _TestLineIterator is UnitTest
  fun name(): String => "line-of-sight:LineIterator"

  fun apply(h: TestHelper) =>
    var pos1 = Pos(0, 0)
    var pos2 = Pos(5, 5)
    var iter = LineIterator(pos1, pos2)
    for pos in iter do
      Debug(pos.string())
    end

    pos1 = Pos(0, 0)
    pos2 = Pos(-5, -9)
    iter = LineIterator(pos1, pos2)
    for pos in iter do
      Debug(pos.string())
    end

    // h.assert_eq[Pos val](p1.perimeter_space(i), perimeter_ans(i))
