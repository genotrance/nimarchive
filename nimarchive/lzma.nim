import os, strutils

import nimterop/[build, cimport]

const
  baseDir = currentSourcePath.parentDir()/"build/liblzma"

static:
  cDebug()

getHeader(
  "lzma.h",
  giturl = "https://github.com/xz-mirror/xz",
  dlurl = "https://tukaani.org/xz/xz-$1.tar.gz",
  outdir = baseDir,
  conFlags = "--disable-xz --disable-xzdec --disable-lzmadec --disable-lzmainfo"
)
