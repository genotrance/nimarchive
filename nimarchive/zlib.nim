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

      when isDefined(zlibStatic):
        # Don't build shared lib
        var
          cm = outdir / "CMakeLists.txt"
          cmd = cm.readFile()
          cmdo = ""
        for line in cmd.splitLines():
          var line = line
          if "(zlib " in line:
            if "zlibstatic" in line:
              line = line.replace("(zlib ", "(")
            else:
              line = ""
          elif " zlib " in line:
            line = line.replace(" zlib ", " ")
          elif "zlib)" in line:
            line = line.replace("zlib)", "zlibstatic)")
          if line.len != 0: cmdo &= line & "\n"
        cm.writeFile(cmdo)

  when defined(posix):
    setCmakePositionIndependentCode(outdir)

getHeader(
  header = "zlib.h",
  giturl = "https://github.com/madler/zlib",
  dlurl = "http://zlib.net/zlib-$1.tar.gz",
  outdir = baseDir,
  altNames = "z,zlib"
)

static:
  let
    zconf = baseDir / "buildcache" / "zconf.h"
  if fileExists(zconf):
    cpFile(zconf, baseDir / "zconf.h")

when isDefined(zlibJBB) and isDefined(zlibStatic):
  {.passL: "-no-pie".}
