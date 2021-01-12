import nimarchive
import nimarchive/permissions

import os

let
  dest = "tests/extracted"

proc rmDir(dest: string) =
  while dirExists(dest):
    try:
      makeUserWritableRec(dest)
      removeDir(dest)
    except:
      sleep(100)

for pl in walkDir("tests/payload"):
  echo pl.path

  rmDir(dest)
  try:
    extract(pl.path, dest)
  except:
    quit(1)
  let
    stat = getFileInfo(dest/"LICENSE")

  if stat.size != 1096:
    echo "Failed"
    quit(1)

rmDir(dest)
