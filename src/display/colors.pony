use "../world"

primitive Colors
  fun black(): I32                  => 0
  fun red(): I32                    => 1
  fun green(): I32                  => 2
  fun dark_yellow(): I32            => 3
  fun blue(): I32                   => 4
  fun magenta(): I32                => 5
  fun cyan(): I32                   => 6
  fun light_grey(): I32             => 7
  fun dark_grey(): I32              => 8
  fun pink_orange(): I32            => 9
  fun bright_green(): I32           => 10
  fun yellow(): I32                 => 11
  fun turquoise(): I32              => 14
  fun white(): I32                  => 15
  fun orange(): I32                 => 202
  fun lava_red(): I32               => 196

  fun light_tan(): I32              => 246
  fun mid_tan(): I32                => 242
  fun dark_tan(): I32               => 236
  fun light_green(): I32            => 46
  fun mid_green(): I32              => 76 //2
  fun dark_green(): I32             => 29 //28
  fun light_brown(): I32            => 179 //178
  fun mid_brown(): I32              => 136
  fun dark_brown(): I32             => 94
  fun ocean_blue(): I32             => 21

primitive ElevationColors
  fun apply(code: ISize): I32 =>
    match code
    | -1 => Colors.ocean_blue()
    | 0 => Colors.light_tan()
    | 1 => Colors.mid_tan()
    | 2 => Colors.dark_tan()
    | 3 => Colors.light_green()
    | 4 => Colors.mid_green()
    | 5 => Colors.dark_green()
    | 6 => Colors.light_brown()
    | 7 => Colors.mid_brown()
    | 8 => Colors.dark_brown()
    else
      Colors.ocean_blue()
    end

primitive TerrainColors
  fun apply(t: Terrain val): I32 =>
    match t
    | Plain => Colors.black()
    | Wall => Colors.dark_tan()
    | Forest => Colors.green()
    | Hill => Colors.orange()
    | Floor => Colors.black()
    | Lava => Colors.lava_red()
    | Undug => Colors.dark_grey()
    | Void => Colors.blue()
    else
      Colors.black()
    end