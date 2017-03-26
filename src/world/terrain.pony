trait Terrain
  fun is_passable(): Bool => true
  fun is_transparent(): Bool => true
  fun is_discoverable(): Bool => false
  fun description(): String

primitive Plain is Terrain
  fun description(): String => "empty plains"

primitive Forest is Terrain
  fun description(): String => "a forest"

primitive Hill is Terrain
  fun description(): String => "hills"

primitive Floor is Terrain
  fun description(): String => "the floor"

primitive Wall is Terrain
  fun is_passable(): Bool => false
  fun is_transparent(): Bool => false
  fun is_discoverable(): Bool => true
  fun description(): String => "a wall"

primitive Door is Terrain
  fun is_transparent(): Bool => false
  fun description(): String => "a door"

primitive Lava is Terrain
  fun description(): String => "some lava"

primitive Undug is Terrain
  fun is_passable(): Bool => false
  fun is_transparent(): Bool => false
  fun description(): String => ", well, you can't tell"

primitive Void is Terrain
  fun is_passable(): Bool => false
  fun is_transparent(): Bool => false
  fun description(): String => ", well, you can't tell"
