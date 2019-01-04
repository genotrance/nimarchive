import nimarchive

import os

let
  dest = "tests/extracted"

for pl in walkDir("tests/payload"):
  echo pl.path

  removeDir(dest)
  try:
    extract(pl.path, dest)
  except:
    quit(1)
  let
    stat = getFileInfo(dest/"LICENSE")

  if stat.size != 1096:
    echo "Failed"
    quit(1)

removeDir(dest)
