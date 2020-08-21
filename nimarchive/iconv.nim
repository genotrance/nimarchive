import os, strutils

import nimterop/build

const
  baseDir = getProjectCacheDir("nimarchive" / "iconv")

getHeader(
  header = "iconv.h",
  dlurl = "https://ftp.gnu.org/gnu/libiconv/libiconv-$1.tar.gz",
  conanuri = "libiconv",
  jbburi = "Libiconv",
  jbbFlags = "url=https://bintray.com/genotrance/binaries/download_file?file_path=Libiconv-v$1/",
  outdir = baseDir,
  conFlags = "--enable-static=yes --with-pic=yes"
)
