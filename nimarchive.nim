import os

import nimarchive/archive

proc check(err: cint, arch: ptr archive, verbose=false) =
  if err < ARCHIVE_OK and verbose:
    echo $arch.archive_error_string() & ": " & $err
  if err < -20:
    if not verbose:
      echo $arch.archive_error_string() & ": " & $err
    raise newException(Exception, "Fatal failure")

proc copyData(arch: ptr archive, ext: ptr archive, verbose=false): cint =
  var
    ret: cint
    buf: pointer
    size: uint
    offset: la_int64_t

  while true:
    ret = arch.archive_read_data_block(addr buf, addr size, addr offset)
    if ret == ARCHIVE_EOF:
      return ARCHIVE_OK
    if ret < ARCHIVE_OK:
      return ret

    ret = ext.archive_write_data_block(buf, size, offset).cint
    if ret < ARCHIVE_OK:
      ret.check(ext, verbose)
      return ret

proc extract*(path: string, extractDir: string, verbose=false) =
  ## Extracts the archive ``path`` into the specified ``directory``.
  ##
  ## ``verbose`` - if ``true``, more verbose warnings are echoed to stdout
  var
    arch = archive_read_new()
    ext = archive_write_disk_new()
    entry: ptr archive_entry
    ret: cint
    currDir = getCurrentDir()

  arch.archive_read_support_format_all().check(arch, verbose)

  arch.archive_read_support_compression_all().check(arch, verbose)

  ext.archive_write_disk_set_options(102).check(ext, verbose)

  ext.archive_write_disk_set_standard_lookup().check(ext, verbose)

  arch.archive_read_open_filename(path.cstring, 10240).check(arch, verbose)

  createDir(extractDir)
  setCurrentDir(extractDir)
  defer:
    setCurrentDir(currDir)

  while true:
    ret = arch.archive_read_next_header(addr entry)
    if ret == ARCHIVE_EOF:
      break
    ret.check(arch, verbose)

    ext.archive_write_header(entry).check(ext, verbose)

    if entry.archive_entry_size() > 0:
      arch.copyData(ext, verbose).check(arch, verbose)

    ext.archive_write_finish_entry().check(ext, verbose)

  arch.archive_read_free().check(arch, verbose)
  ext.archive_write_free().check(ext, verbose)
