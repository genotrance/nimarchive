import os, strutils

import nimterop/build

const
  baseDir = getProjectCacheDir("nimarchive" / "bzip2")

proc bzlibPreBuild(outdir, path: string) {.used.} =
  var
    mf = baseDir / "Makefile"
    mfd = mf.readFile()
  when defined(windows):
    mfd = mfd.multiReplace([("rm -f", "cmd /c del /q"), ("@cat", "@cmd /c type")])
  else:
    mfd = mfd.replace("CFLAGS=-Wall", "CFLAGS=-fPIC -Wall")

  # Allow env var overrides of compiler
  mfd = mfd.multiReplace([("CC=", "CC?="), ("LDFLAGS=", "LDFLAGS?=")])

  mf.writeFile(mfd)

getHeader(
  "bzlib.h",
  "https://github.com/genotrance/bzip2",
  outdir = baseDir,
  altNames = "bz2",
  makeFlags = "libbz2.a"
)
