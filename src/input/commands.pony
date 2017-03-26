trait Cmd
  fun string(): String

primitive EmptyCmd is Cmd
  fun string(): String => "EmptyCmd"

primitive ACmd is Cmd
  fun string(): String => "ACmd"
primitive ECmd is Cmd
  fun string(): String => "ECmd"
primitive NCmd is Cmd
  fun string(): String => "NCmd"
primitive UCmd is Cmd
  fun string(): String => "UCmd"
primitive YCmd is Cmd
  fun string(): String => "YCmd"

primitive UpCmd is Cmd
  fun string(): String => "UpCmd"
primitive DownCmd is Cmd
  fun string(): String => "DownCmd"
primitive LeftCmd is Cmd
  fun string(): String => "LeftCmd"
primitive RightCmd is Cmd
  fun string(): String => "RightCmd"

primitive UpStairsCmd is Cmd
  fun string(): String => "UpStairsCmd"
primitive DownStairsCmd is Cmd
  fun string(): String => "DownStairsCmd"    

primitive WaitCmd is Cmd
  fun string(): String => "WaitCmd"
primitive InventoryModeCmd is Cmd
  fun string(): String => "InventoryModeCmd"
primitive DropCmd is Cmd
  fun string(): String => "DropCmd"
primitive TakeCmd is Cmd
  fun string(): String => "TakeCmd"
primitive LookCmd is Cmd
  fun string(): String => "LookCmd"
primitive HelpCmd is Cmd
  fun string(): String => "HelpCmd"
primitive EnterCmd is Cmd
  fun string(): String => "EnterCmd"
primitive FastCmd is Cmd
  fun string(): String => "FastCmd"
primitive ViewCmd is Cmd
  fun string(): String => "ViewCmd"
primitive EscCmd is Cmd
  fun string(): String => "EscCmd"
primitive ResetCmd is Cmd
  fun string(): String => "ResetCmd"
primitive QuitCmd is Cmd
  fun string(): String => "QuitCmd"

