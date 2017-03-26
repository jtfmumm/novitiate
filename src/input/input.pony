use "term"
use "../game"
use "../datast"
use "../display"

class InputNotify
  """
  Receive input from an ANSITerm.
  """
  var _initialized: Bool = false
  let _game: Game

  new iso create(game: Game) =>
    _game = game

  fun is_recognized(cmd: Cmd val): Bool =>
    cmd isnt EmptyCmd

  fun ref apply(term: ANSITerm ref, input: U8) =>
    let cmd = KeyTranslator(input)
    if is_recognized(cmd) then
      _game(cmd)
    end

  fun ref up(ctrl: Bool, alt: Bool, shift: Bool) =>
    _game(UpCmd)

  fun ref down(ctrl: Bool, alt: Bool, shift: Bool) =>
    _game(DownCmd)

  fun ref left(ctrl: Bool, alt: Bool, shift: Bool) =>
    _game(LeftCmd)

  fun ref right(ctrl: Bool, alt: Bool, shift: Bool) =>
    _game(RightCmd)

  fun ref delete(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref insert(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref home(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref end_key(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref page_up(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref page_down(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref fn_key(i: U8, ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref prompt(term: ANSITerm ref, value: String) =>
    None

  fun ref size(rows: U16, cols: U16) =>
    if (rows < 31) or (cols < 99) then
      ifdef not windows then
        _game.fail_term_too_small()
      end
    else
      if not _initialized then
        _game.start()
        _initialized = true
      end
    end

  fun ref closed() =>
    None
