#!/bin/bash

cd "$(dirname "$0")"

set -e

export=./export
game=obersprengmeister

rm -r $export
mkdir -p $export
touch $export/.gdignore

# This creates the .pck file four times.
godot --no-window --export 'HTML5' $export/index.html
godot --no-window --export 'Linux/X11' $export/$game.x86_64
godot --no-window --export 'Windows Desktop' $export/$game.exe
godot --no-window --export 'Mac OSX' $export/$game-mac.zip

(
  cd $export

  tar cjf $game-linux.tar.bz2 $game.x86_64 $game.pck
  rm $game.x86_64

  zip $game-windows.zip $game.exe $game.pck
  rm $game.exe
)
