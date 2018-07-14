use "../datast"
use "../inventory"
use "../world"

primitive NovitiateDisplayAdapter is DisplayAdapter[Tiles]
  fun apply(t: Tiles, col: I32, row: I32): (Glyph, Color) ? =>
    let tile: Tile = t(Pos(col, row))?
    if tile.is_visible() then
      let background =
        if tile.is_highlighted() then
          Colors.yellow()
        elseif tile.elevation >= 0 then
          ElevationColors(tile.elevation)
        else
          TerrainColors(tile.terrain)
        end
      let display_char =
        if tile.is_occupied() then
          DisplayChars(tile.occupant_code)
        elseif tile.has_item() then
          try
            let i = tile.item as Item val
            ItemDisplayChars(i)
          else
            TerrainDisplayChars(tile.terrain)
          end
        elseif tile.has_landmark() then
          LandmarkDisplayChars(tile.landmark)
        else
          TerrainDisplayChars(tile.terrain)
        end
      (display_char, background)
    else
      if tile.is_highlighted() then
        (" ", Colors.yellow())
      elseif tile.has_staircase() and tile.has_been_seen() then
        (LandmarkDisplayChars(tile.landmark), Colors.black())
      elseif tile.has_been_seen() then
        (" ", Colors.black())
      else
        (" ", TerrainColors(Undug))
      end
    end
