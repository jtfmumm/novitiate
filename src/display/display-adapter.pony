type Glyph is String
type Color is I32

trait DisplayAdapter[M: Any #read]
  fun apply(map: M, col: I32, row: I32): (Glyph, Color) ?
