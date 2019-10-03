import os, strutils

import nimterop/build

const
  baseDir = currentSourcePath.parentDir().parentDir() / "build" / "zlib"

proc zlibPreBuild(outdir, path: string) =
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
  cpFile(baseDir / "buildcache" / "zconf.h", baseDir / "zconf.h")
