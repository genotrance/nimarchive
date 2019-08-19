import os, strutils

import nimterop/[cimport, git]

const
  path = getTempDir() / "nimarchive"
  adoth = path/"libarchive/libarchive/archive.h"

  lzma = path/"liblzma"
  lzmasrc = lzma/"src/liblzma"
  zlib = path/"zlib"
  libarchive = path/"libarchive"

static:
  var conFlags = ""

  # liblzma
  gitPull("https://github.com/kobolabs/liblzma", lzma)
  for i in ["xz", "xzdec", "lzmadec", "lzmainfo", "shared"]:
    conFlags &= " --disable-$#" % i
  configure(lzma, "Makefile", conFlags)
  make(lzmasrc, ".libs/liblzma.a", "-j 2")

  # zlib
  gitPull("https://github.com/madler/zlib", zlib)
  configure(zlib, "configure.log", "--static")
  make(zlib, "libz.a")

  putEnv("CFLAGS", "-DHAVE_LIBLZMA=1 -DHAVE_LZMA_H=1 -DHAVE_LIBZ=1 -DHAVE_ZLIB_H=1 -I" &
    (lzmasrc/"api").replace("\\", "/").replace("C:", "/c") & " -I" & zlib.replace("\\", "/").replace("C:", "/c"))

  # libarchive
  gitPull("https://github.com/libarchive/libarchive", libarchive)

  conFlags = ""
  for i in ["lzma", "zlib", "bz2lib", "nettle", "openssl", "libb2", "lz4", "zstd", "xml2", "expat"]:
    conFlags &= " --without-$#" % i
  for i in ["shared", "bsdtar", "bsdcat", "bsdcpio", "acl"]:
    conFlags &= " --disable-$#" % i
  configure(libarchive/"build", "../configure")
  configure(libarchive, "Makefile", conFlags)

  make(libarchive, ".libs/libarchive.a", "libarchive.la -j 2")

  writeFile(adoth, readFile(adoth) & "\n#include \"archive_entry.h\"\n")

  cDebug()
  cSkipSymbol(@["archive_read_open_file", "archive_write_open_file"])

  {.passL: libarchive/".libs/libarchive.a" & " " & lzmasrc/".libs/liblzma.a" & " " & zlib/"libz.a".}

cPlugin:
  import macros, strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    if sym.kind in [nskParam]:
      sym.name = sym.name.strip(chars={'_'})

type
  stat {.importc: "struct stat", header: "sys/stat.h".} = object
  dev_t = int32
  mode_t = uint32

when defined(windows):
  type
    BY_HANDLE_FILE_INFORMATION = object

  {.passC: "-DHAVE_CONFIG_H -std=c99 -I" & libarchive.}
  {.passL: "-lbcrypt".}
  cCompile(path / "libarchive/libarchive/*_windows.c")

cImport(adoth, recurse=true)
