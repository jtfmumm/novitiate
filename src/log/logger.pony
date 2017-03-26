primitive Logger
  fun info(s: String) => @printf[I32](("[INFO] " + s + "\n").cstring())
  fun err(s: String) => @printf[I32](("[ERROR] " + s + "\n").cstring())
