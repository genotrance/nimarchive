import os, strutils

import nimterop/build

const
  baseDir = getProjectCacheDir("nimarchive" / "zlib")

proc zlibPreBuild(outdir, path: string) {.used.} =
  let
    mf = outdir / "Makefile"
  if mf.fileExists():
    # Delete default Makefile
    if mf.readFile().contains("configure first"):
      mf.rmFile()
      when defined(windows):
        # Fix static lib name on Windows
        setCmakeLibName(outdir, "zlibstatic", prefix = "lib", oname = "zlib", suffix = ".a")

  when defined(posix):
    setCmakePositionIndependentCode(outdir)

getHeader(
  "zlib.h",
  giturl = "https://github.com/madler/zlib",
  dlurl = "http://zlib.net/zlib-$1.tar.gz",
  outdir = baseDir,
  altNames = "z"
)

static:
  let
    zconf = baseDir / "buildcache" / "zconf.h"
  if fileExists(zconf):
    cpFile(zconf, baseDir / "zconf.h")
