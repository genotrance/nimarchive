# Package

version       = "0.2.1"
author        = "genotrance"
description   = "libarchive wrapper for Nim"
license       = "MIT"

skipDirs = @["tests"]

# Dependencies

requires "nimterop#v020"

var
  name = "nimarchive"

task test, "Run tests":
  exec "nim c --debugger:native --debuginfo -r tests/t" & name & ".nim"
  exec "nim c --debugger:native --debuginfo -r tests/t" & name & "_extract.nim"
  exec "nim c -d:release -r tests/t" & name & ".nim"
  exec "nim c -d:release -r tests/t" & name & "_extract.nim"
