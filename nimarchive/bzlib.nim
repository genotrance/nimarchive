import os, strutils

import nimterop/build

const
  baseDir = currentSourcePath.parentDir()/"build"/"bzip2"

proc bzlibPreBuild(outdir, path: string) =
  when defined(windows):
    let
      mf = baseDir / "Makefile"
      mfd = mf.readFile().multiReplace([("rm -f", "cmd /c del /q"), ("@cat", "@cmd /c type")])

    mf.writeFile(mfd)

getHeader(
  "bzlib.h",
  "https://sourceware.org/git/bzip2.git",
  "https://sourceware.org/pub/bzip2/bzip2-$1.tar.gz",
  outdir = baseDir,
  altNames = "bz2",
  makeFlags = "libbz2.a"
)
