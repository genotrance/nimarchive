import os, strutils

import nimterop/build

const
  baseDir = getProjectCacheDir("nimarchive" / "liblzma")

  conFlags = block:
    var
      cf = flagBuild("--disable-$#", ["xz", "xzdec", "lzmadec", "lzmainfo"])
    when defined(posix):
      cf &= " CFLAGS=-fPIC CXXFLAGS=-fPIC"
    cf

getHeader(
  "lzma.h",
  giturl = "https://github.com/xz-mirror/xz",
  dlurl = "https://tukaani.org/xz/xz-$1.tar.gz",
  outdir = baseDir,
  conFlags = conFlags
)
