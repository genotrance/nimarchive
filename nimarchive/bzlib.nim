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

  mf.writeFile(mfd)

getHeader(
  "bzlib.h",
  "https://sourceware.org/git/bzip2.git",
  "https://sourceware.org/pub/bzip2/bzip2-$1.tar.gz",
  outdir = baseDir,
  altNames = "bz2",
  makeFlags = "libbz2.a"
)
