import os, strutils, strformat

import nimterop/[build, cimport]

import bzlib, lzma, zlib

const
  baseDir = currentSourcePath.parentDir() / "build" / "libarchive"

static:
  cDebug()

proc mPath(path: string): string =
  when defined(windows):
    result = path.replace("\\", "/")
  else:
    result = path
  result = result.quoteShell

const
  conFlags = block:
    var cf = ""
    for i in ["lzma", "zlib", "bz2lib", "nettle", "openssl", "libb2", "lz4", "zstd", "xml2", "expat"]:
      cf &= " --without-$#" % i
    for i in ["shared", "bsdtar", "bsdcat", "bsdcpio", "acl"]:
      cf &= " --disable-$#" % i
    cf

  cmakeFlags = block:
    let
      incpath = (lzmaPath.parentDir() & ";" & zlibPath.parentDir() & ";" & bzlibPath.parentDir()).mPath()
      llp = lzmaLPath.mPath()
      zlp = zlibLPath.mPath()
      blp = bzlibLPath.mPath()
    var cf = &"-DCMAKE_INCLUDE_PATH={incpath} -DLIBLZMA_LIBRARY={llp} -DZLIB_LIBRARY={zlp} -DBZIP2_LIBRARY_RELEASE={blp}"
    cf

proc archivePreBuild(outdir, path: string) =
  #~ putEnv("CFLAGS", "-DHAVE_LIBLZMA=1 -DHAVE_LZMA_H=1 -DHAVE_LIBZ=1 -DHAVE_ZLIB_H=1 -I" &
    #~ lzmaPath.parentDir().replace("\\", "/").replace("C:", "/c") & " -I" &
    #~ zlibPath.parentDir().replace("\\", "/").replace("C:", "/c"))
  let
    rf = readFile(path)
    str = "\n#include \"archive_entry.h\"\n"
  if not rf.contains(str):
    writeFile(path, rf & str)

getHeader(
  "archive.h",
  "https://github.com/libarchive/libarchive",
  "https://libarchive.org/downloads/libarchive-$1.zip",
  outdir = baseDir,
  conFlags = conFlags,
  cmakeFlags = cmakeFlags
)

cPlugin:
  import strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    if sym.kind in [nskParam]:
      sym.name = sym.name.strip(chars={'_'})

cOverride:
  type
    stat* {.importc: "struct stat", header: "sys/stat.h".} = object
    dev_t* = int32
    mode_t* = uint32

  when defined(windows):
    type
      BY_HANDLE_FILE_INFORMATION* = object

    {.passL: "-lbcrypt".}

static:
  cSkipSymbol(@["archive_read_open_file", "archive_write_open_file"])

when not defined(archiveStatic):
  cImport(archivePath, recurse = true, dynlib = "archiveLPath")
else:
  cImport(archivePath, recurse = true)
  {.passL: bzlibLPath.}
  {.passL: lzmaLPath.}
  {.passL: zlibLPath.}