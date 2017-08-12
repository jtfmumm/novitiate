use "random"
use "time"
use "../datast"
use "../world"

primitive DiamondSquare
  fun apply(diameter: I32, diameter_per_region: I32, rand: Random):
    Matrix[F64] ?
  =>
    _DiamondSquare(diameter, diameter_per_region)(rand)?

class _DiamondSquare
  let _diameter_per_region: I32
  let _diameter: I32

  new create(diameter: I32, diameter_per_region: I32) =>
    _diameter_per_region = diameter_per_region
    _diameter = diameter

  fun apply(rand: Random): Matrix[F64] iso^ ? =>
    var matrix: Matrix[F64] iso = create_corner_values(rand)?
    let d_per_region = _diameter_per_region

    //Run diamondSquare on each subsection and add it as a matrix to newMatrixOfMatrices
    var y: I32 = 0
    var x: I32 = 0
    while y < _diameter do
      while x < _diameter do
        matrix = diamond_square(consume matrix, x, y, d_per_region, rand)
        x = x + _diameter_per_region
      end
      x = 0
      y = y + _diameter_per_region
    end
    consume matrix

  fun create_corner_values(rand: Random): Matrix[F64] iso^ ? =>
    let d = _diameter
    let matrix: Matrix[F64] iso = recover Matrix[F64](d, d) end

    //Top
    var x: I32 = 0
    while x < _diameter do
      let point = _random_elevation(rand)
      matrix(Pos(x, 0))? = point + _small_noise(rand)
      if (x - 1) > 0 then
        matrix(Pos(x - 1, 0))? = point + _small_noise(rand)
      end
      x = x + _diameter_per_region
    end

    //Right
    var y: I32 = 0
    while y < _diameter do
      let point = _random_elevation(rand)
      matrix(Pos(_diameter - 1, y))? = point + _small_noise(rand)
      if (y - 1) > 0 then
        matrix(Pos(_diameter - 1, y - 1))? = point + _small_noise(rand)
      end
      y = y + _diameter_per_region
    end

    matrix(Pos(d - 1, d - 1))? = _random_elevation(rand)

    //Bottom
    x = 0
    while x < _diameter do
      let point = _random_elevation(rand)
      matrix(Pos(x, _diameter - 1))? = point + _small_noise(rand)
      if (x - 1) > 0 then
        matrix(Pos(x - 1, _diameter - 1))? = point + _small_noise(rand)
      end
      x = x + _diameter_per_region
    end

    //Remaining
    x = 0
    y = 0
    while y < _diameter do
      while x < _diameter do
        let point = _random_elevation(rand)
        matrix(Pos(x, y))? = point + _small_noise(rand)
        if (y - 1) > 0 then
          matrix(Pos(x, y - 1))? = point + _small_noise(rand)
        end
        if (x - 1) > 0 then
          matrix(Pos(x - 1, y))? = point + _small_noise(rand)
        end
        if ((x - 1) > 0) and ((y - 1) > 0) then
          matrix(Pos(x - 1, y - 1))? = point + _small_noise(rand)
        end
        x = x + _diameter_per_region
      end
      x = 0
      y = y + _diameter_per_region
    end

    consume matrix

  fun diamond_square(m: Matrix[F64] iso, x: I32, y: I32,
    diameter: I32, rand: Random): Matrix[F64] iso^
  =>
    var matrix: Matrix[F64] iso = consume m
    let midpoint: I32 = _find_midpoint(diameter)
    try
      let nw: F64 = matrix(Pos(x, y))?
      let ne: F64 = matrix(Pos(x + (diameter - 1), y))?
      let sw: F64 = matrix(Pos(x, y + (diameter - 1)))?
      let se: F64 = matrix(Pos(x + (diameter - 1), y + (diameter - 1)))?
      matrix(Pos(x + midpoint, y + midpoint))? = ((nw + ne + sw + se) / 4) + _small_noise(rand)
      matrix(Pos(x, y + midpoint))? = ((nw + sw) / 2) + _small_noise(rand)
      matrix(Pos(x + (diameter - 1), y + midpoint))? = ((ne + se) / 2) + _small_noise(rand)
      matrix(Pos(x + midpoint, y))? = ((nw + ne) / 2) + _small_noise(rand)
      matrix(Pos(x + midpoint, y + (diameter - 1)))? = ((sw + se) / 2) + _small_noise(rand)
    else
      @printf[None](("Failed!\n").cstring())
    end
    if midpoint == 1 then return consume matrix end
    matrix = diamond_square(consume matrix, x, y, midpoint + 1, rand)
    matrix = diamond_square(consume matrix, x, y + midpoint, midpoint + 1,
      rand)
    matrix = diamond_square(consume matrix, x + midpoint, y, midpoint + 1,
      rand)
    matrix = diamond_square(consume matrix, x + midpoint, y + midpoint,
      midpoint + 1, rand)

    consume matrix

  fun _find_midpoint(diameter: I32): I32 =>
      diameter / 2

  fun _random_elevation(rand: Random): F64 =>
      rand.int(9).f64()

  fun _small_noise(rand: Random): F64 =>
      (rand.real() - 0.5) / 2
