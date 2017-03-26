primitive Invariant is _InvariantFailure
  """
  This is a debug only assertion. If the test is false, it will print
  'Invariant violated' along with the source file location of the
  invariant to stderr and then forcibly exit the program.
  """
  fun apply(test: Bool, loc: SourceLoc = __loc) =>
    ifdef debug then
      if not test then
        fail(loc)
      end
    end

primitive LazyInvariant is _InvariantFailure
  """
  This is a debug only assertion. If the test is false or throws an error,
  it will print 'Invariant violated' along with the source file location
  of the invariant to stderr and then forcibly exit the program.
  """
  fun apply(f: {(): Bool ?}, loc: SourceLoc = __loc) =>
    ifdef debug then
      try
        if not f() then
          fail(loc)
        end
      else
        fail(loc)
      end
    end

trait _InvariantFailure
  """
  Common failure handling scheme for invariants.
  """
  fun fail(loc: SourceLoc) =>
    @fprintf[I32](
      @pony_os_stderr[Pointer[U8]](),
      "Invariant violated in %s at line %s\n".cstring(),
      loc.file().cstring(),
      loc.line().string().cstring())
    @exit[None](U8(1))
