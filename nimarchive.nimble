# Package

version       = "0.1.1"
author        = "genotrance"
description   = "libarchive wrapper for Nim"
license       = "MIT"

skipDirs = @["tests"]

# Dependencies

requires "nimgen >= 0.2.2"

import distros

var cmd = ""
if detectOs(Windows):
    cmd = "cmd /c "

task setup, "Download and generate":
    exec cmd & "nimgen nimarchive.cfg"

before install:
    setupTask()

task test, "Test":
    exec "nim c -r tests/testarch.nim"
