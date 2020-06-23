import os, strutils

import nimterop/build

const
  baseDir = getProjectCacheDir("nimarchive" / "iconv")

getHeader(
  header = "iconv.h",
  dlurl = "https://ftp.gnu.org/gnu/libiconv/libiconv-$1.tar.gz",
  conanuri = "libiconv",
  jbburi = "libiconv",
  outdir = baseDir,
  conFlags = "--enable-static=yes"
)
