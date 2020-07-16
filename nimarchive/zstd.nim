import os, strutils

import nimterop/build

const
  baseDir = getProjectCacheDir("nimarchive" / "zstd")

getHeader(
  header = "zstd.h",
  outdir = baseDir
)
