import os, strutils

import nimterop/[build, cimport]

static:
  cDebug()

const
  baseDir = getProjectCacheDir("nimarchive" / "libarchive")

  defs = """
    archiveStatic
    archiveJBB
    archiveSetVer=3.4.3

    iconvStatic
    iconvStd
    iconvConan
    iconvSetVer=1.16
  """

setDefines(defs.splitLines())

getHeader(
  header = "archive.h",
  outdir = baseDir,
  jbburi = "LibArchive",
  jbbFlags = "url=https://bintray.com/genotrance/binaries/download_file?file_path=LibArchive-v$1/ skip=libiconv"
)

import iconv

cPlugin:
  import strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    sym.name = sym.name.strip(chars={'_'}).replace("___", "_")

cOverride:
  type
    stat* {.importc: "struct stat", header: "sys/stat.h".} = object
    dev_t* = int32
    mode_t* = uint32

type
  LA_MODE_T* = int

when defined(windows):
  cPassL("-lbcrypt")
  cOverride:
    type
      BY_HANDLE_FILE_INFORMATION* = object

static:
  cSkipSymbol(@["archive_read_open_file", "archive_write_open_file"])

let
  archiveEntryPath {.compileTime.} = archivePath[0 .. ^3] & "_entry.h"

when archiveStatic:
  cImport(@[archivePath, archiveEntryPath], recurse = true)
else:
  cImport(@[archivePath, archiveEntryPath], recurse = true, dynlib = archiveLPath)
