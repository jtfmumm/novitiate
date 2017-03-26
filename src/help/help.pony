primitive Help
  fun apply(): Array[String] =>
    /////////////////////////////////////////////////////////////////
    recover [
      "***************HELP (press h or esc to return)***************",
      "",
      "NORMAL MODE (moving around map):",
      "<arrows> - movement / attack ",
      ". - wait (turn passes without action)",
      "i - enter INVENTORY MODE",
      "l - enter LOOK MODE (inspect tiles from a distance)",
      "v - enter VIEW MODE (jump around map)",
      "t - (t)ake item on tile",
      "> - descend stairs",
      "< - ascend stairs",
      "<enter> - inspect tile you're on (and see item type)",
      "q - quit",
      "",
      "INVENTORY MODE:",
      "<arrows> - move through items",
      "<enter> - equip/drink/use",
      "l - (l)ook at item",
      "d - (d)rop item",
      "i/<esc> - return to NORMAL MODE",
      "",
      "LOOK MODE/VIEW MODE:",
      "<arrows> - look around",
      "<enter> - inspect tile (in LOOK MODE)",
      "<esc> - return to NORMAL MODE",
      "**************************************************************"
    ] end
