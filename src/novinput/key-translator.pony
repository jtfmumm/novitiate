primitive KeyTranslator
  fun apply(ch: U8): Cmd val =>
    match ch
    | Keys.left() => LeftCmd
    | Keys.right() => RightCmd
    | Keys.up() => UpCmd
    | Keys.down() => DownCmd
    | Keys.enter() => EnterCmd
    | Keys.escape() => EscCmd

    | 'a' => ACmd
    | 'e' => ECmd
    | 'n' => NCmd
    | 'u' => UCmd
    | 'y' => YCmd

    | 'd' => DropCmd
    | 'f' => FastCmd
    | 'h' | '?' => HelpCmd
    | 'i' => InventoryModeCmd
    | 'l' => LookCmd
    | 'r' => ResetCmd
    | 't' => TakeCmd
    | 'v' => ViewCmd
    | '.' => WaitCmd
    | '<' => UpStairsCmd
    | '>' => DownStairsCmd
    | 'q' | 'Q' => QuitCmd
    else
      EmptyCmd
    end
