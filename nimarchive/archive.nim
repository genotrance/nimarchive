import os, strutils

import nimterop/[cimport, git]

const
  path = getTempDir() / "nimarchive"
  adoth = path/"libarchive/libarchive/archive.h"

static:
  gitPull("https://github.com/libarchive/libarchive", path/"libarchive", "libarchive/*")

  gitPull("https://github.com/kobolabs/liblzma", path/"liblzma", "src/liblzma\nsrc/common")

  gitPull("https://github.com/madler/zlib", path/"zlib", "*.h\n*.c")

  var configH =
    when defined(Windows): """
#define id_t short
#define uid_t short
#define gid_t short
#define HAVE_WCSCPY 1
#define HAVE_WCSLEN 1
#define HAVE_WINCRYPT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDBOOL_H 1

#define HAVE_DECL_SIZE_MAX 1
#define HAVE_DECL_SSIZE_MAX 1
"""
    elif defined(Linux): """
#define _XOPEN_SOURCE 500
#define HAVE_ERRNO_H 1
#define HAVE_LIMITS_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_FCNTL 1
#define HAVE_FCNTL_H 1
#define HAVE_WCHAR_H 1
#define HAVE_WCSCPY 1
#define HAVE_WCSLEN 1
#define HAVE_STDINT_H 1
#define HAVE_STDBOOL_H 1
#define HAVE_PWD_H 1
#define HAVE_GETPWUID_R 1
#define HAVE_GETGRGID_R 1
#define HAVE_GETGRNAM_R 1
#define HAVE_DIRENT_H 1
#define HAVE_FCHDIR 1
#define HAVE_GRP_H 1
#define HAVE_STDLIB_H 1
#define HAVE_LSTAT 1
#define HAVE_SYS_UTSNAME_H 1
#define HAVE_POLL 1
#define HAVE_POLL_H 1
#define HAVE_POSIX_SPAWNP 1
#define HAVE_PIPE 1
#define HAVE_FORK 1
#define HAVE_VFORK 1
#define HAVE_SPAWN_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TIME_H 1
#define S_ISVTX __S_ISVTX
#define u_char __u_char
"""
    elif defined(OSX): """
#define HAVE_ERRNO_H 1
#define HAVE_LIMITS_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_FCNTL 1
#define HAVE_FCNTL_H 1
#define HAVE_WCHAR_H 1
#define HAVE_WCSCPY 1
#define HAVE_WCSLEN 1
#define HAVE_STDINT_H 1
#define HAVE_STDBOOL_H 1
#define HAVE_PWD_H 1
#define HAVE_GETPWUID_R 1
#define HAVE_GETGRGID_R 1
#define HAVE_GETGRNAM_R 1
#define HAVE_DIRENT_H 1
#define HAVE_FCHDIR 1
#define HAVE_GRP_H 1
#define HAVE_STDLIB_H 1
#define HAVE_LSTAT 1
#define HAVE_SYS_UTSNAME_H 1
#define HAVE_POLL 1
#define HAVE_POLL_H 1
#define HAVE_POSIX_SPAWNP 1
#define HAVE_PIPE 1
#define HAVE_FORK 1
#define HAVE_VFORK 1
#define HAVE_SPAWN_H 1
#define HAVE_ARC4RANDOM_BUF 1
"""

  configH &= """
#define HAVE_LZMA_H 1
#define HAVE_LIBLZMA 1
#define HAVE_ZLIB_H 1

#define HAVE_CHECK_CRC32 1
#define HAVE_CHECK_CRC64 1
#define HAVE_CHECK_SHA256 1
#define HAVE_DECODER_ARM 1
#define HAVE_DECODER_ARMTHUMB 1
#define HAVE_DECODER_DELTA 1
#define HAVE_DECODER_IA64 1
#define HAVE_DECODER_LZMA1 1
#define HAVE_DECODER_LZMA2 1
#define HAVE_DECODER_POWERPC 1
#define HAVE_DECODER_SPARC 1
#define HAVE_DECODER_X86 1
#define HAVE_ENCODER_ARM 1
#define HAVE_ENCODER_ARMTHUMB 1
#define HAVE_ENCODER_DELTA 1
#define HAVE_ENCODER_IA64 1
#define HAVE_ENCODER_LZMA1 1
#define HAVE_ENCODER_LZMA2 1
#define HAVE_ENCODER_POWERPC 1
#define HAVE_ENCODER_SPARC 1
#define HAVE_ENCODER_X86 1
"""

  writeFile(path/"libarchive/libarchive/config.h", configH)
  writeFile(adoth, readFile(adoth) & "\n#include \"archive_entry.h\"\n")

  cDebug()
  cSkipSymbol(@["archive_read_open_file", "archive_write_open_file"])

cIncludeDir(path/"libarchive/libarchive")

cIncludeDir(path/"liblzma/src/liblzma/api")
cIncludeDir(path/"liblzma/src/common")
cIncludeDir(path/"liblzma/src/liblzma/lz")
cIncludeDir(path/"liblzma/src/liblzma/lzma")
cIncludeDir(path/"liblzma/src/liblzma/common")
cIncludeDir(path/"liblzma/src/liblzma/check")
cIncludeDir(path/"liblzma/src/liblzma/simple")
cIncludeDir(path/"liblzma/src/liblzma/delta")
cIncludeDir(path/"liblzma/src/liblzma/rangecoder")

cIncludeDir(path/"zlib")

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

{.passC: "-DHAVE_CONFIG_H -std=c99".}

cImport(adoth, recurse=true)

cCompile(path / "libarchive/libarchive/archive*.c")

when defined(windows):
  cCompile(path / "libarchive/libarchive/filter_fork_windows.c")
else:
  cCompile(path / "libarchive/libarchive/filter_fork_posix.c")

cCompile(path / "liblzma/src/liblzma/common")
cCompile(path / "liblzma/src/liblzma/lzma", exclude="tablegen")
cCompile(path / "liblzma/src/liblzma/lz")
cCompile(path / "liblzma/src/liblzma/rangecoder", exclude="tablegen")
cCompile(path / "liblzma/src/liblzma/check", exclude="small,tablegen")
cCompile(path / "liblzma/src/liblzma/simple")
cCompile(path / "liblzma/src/liblzma/delta")
cCompile(path / "liblzma/src/common")
cCompile(path / "zlib/*.c", exclude="contrib,examples,test")

