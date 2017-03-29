# Acolyte

A procedurally generated RPG inspired by Rogue and written in Pony.

This is a work in progress but you can currently play complete games.
Because everything is procedurally generated, it's a different game
every time.

NOTE: Acolyte is currently tested with ponyc v0.11.4. It may break
with later ponyc releases.

* [Acolyte Instructions](#acolyte-instructions)
* [Installation](#installation)
* [Running](#running)

![Acolyte](/images/screenshot.png?raw=true "Acolyte")

## Acolyte Instructions

Acolyte is played from the terminal.

The object of the game is to find the Staff of Eternity.  

### Commands

```
NORMAL MODE (moving around map):
<arrows> - movement / attack (collide with enemy)
h - (h)elp
. - wait (turn passes without action)
i - enter INVENTORY MODE
l - enter LOOK MODE (inspect tiles from a distance)
v - enter VIEW MODE (jump around map)
t - (t)ake item on tile
> - descend stairs
< - ascend stairs 
<enter> - inspect tile you're on (and see item type)
q - quit

LOOK MODE (inspect objects around map):
<arrows> - move look cursor
enter - look at highlighted tile
l - return to NORMAL MODE
<esc> - return to NORMAL MODE

VIEW MODE (rapidly look around map):
<arrows> - jump view by partial screen
v - return to NORMAL MODE
<esc> - return to NORMAL MODE

INVENTORY MODE:
<arrows> - move through items
enter - equip weapon or armor / drink potion / use misc item 
l - (l)ook at item
d - (d)rop item
i - return to NORMAL MODE
<esc> - return to NORMAL MODE
```

### Objects

```
@ - the acolyte
[a-z,A-Z] - beings of all kinds
# - wall
% - weapon or armor
! - potion
$ - cold, hard cash
> - descending stairs
< - ascending stairs 
? - who knows!
```

## Installation

Currently, Acolyte is only supported on OSX.

### Building on Mac OS X

#### Building ponyc
You'll need llvm 3.7.1 or 3.8.1 and the pcre2 library to build Pony. You can use either homebrew or MacPorts to install these dependencies.

##### Get Dependencies via Homebrew
Installation via [homebrew](http://brew.sh):
```
$ brew update
$ brew install homebrew/versions/llvm38 pcre2 libressl
```

##### Get Dependencies via MacPorts
Installation via [MacPorts](https://www.macports.org):
```
$ sudo port install llvm-3.8 pcre2 libressl
$ sudo port select --set llvm mp-llvm-3.8
```

##### Install compiler
Clone the ponyc repo and install the compiler (Acolyte is tested with ponyc 
v0.11.4):
```
git clone https://github.com/ponylang/ponyc
cd ponyc
git checkout 0.11.4
make config=release install
```

#### Building Acolyte
```
git clone https://github.com/jtfmumm/acolyte
cd acolyte
ponyc
chmod +x acolyte
```

## Running
Your terminal must have dimensions of at least 99x31 to run the game properly. 

Assuming you've set execute permissions (e.g. via `chmod +x acolyte`), you can run the game with the following command:
```
./acolyte
```



