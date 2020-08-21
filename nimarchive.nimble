# Package

version       = "0.5.3"
author        = "genotrance"
description   = "libarchive wrapper for Nim"
license       = "MIT"

skipDirs = @["tests"]

# Dependencies

requires "nimterop >= 0.6.6"

var
  name = "nimarchive"

when gorgeEx("nimble path nimterop").exitCode == 0:
  import nimterop/docs
  task docs, "Generate docs": buildDocs(@["nimarchive.nim"], "build/htmldocs")
else:
  task docs, "Do nothing": discard

task test, "Run tests":
  exec "nim c --path:.. -f -d:release -r tests/t" & name & ".nim"
  exec "nim c --path:.. -d:release -r tests/t" & name & "_extract.nim"
  docsTask()
