use "../world"

primitive SimpleTiles
  fun apply(diameter: I32): Tiles iso^ =>
    recover
      Tiles(diameter, diameter, {(): Tile =>
        Tile(EmptyOccupant, OccupantCodes.none(), Floor)})
    end
