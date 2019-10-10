# Package

version       = "0.3.0"
author        = "genotrance"
description   = "libarchive wrapper for Nim"
license       = "MIT"

skipDirs = @["tests"]

# Dependencies

requires "nimterop#head"

var
  name = "nimarchive"

when gorgeEx("nimble path nimterop").exitCode == 0:
  import nimterop/docs
  task docs, "Generate docs": buildDocs(@["nimarchive.nim"], "build/htmldocs")
else:
  task docs, "Do nothing": discard

task test, "Run tests":
  exec "nim c -f -d:release -r tests/t" & name & ".nim"
  exec "nim c -d:release -r tests/t" & name & "_extract.nim"
  docsTask()
