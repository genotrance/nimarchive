import hashes, os, times

import nimarchive/archive
import nimarchive/permissions

proc check(err: cint, arch: ptr archive, verbose=false) =
  if err < ARCHIVE_OK and verbose:
    # Echo warnings and errors if verbose
    echo $arch.archive_error_string() & ": " & $err
  if err < -20:
    if not verbose:
      # Always echo errors
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

proc extract*(path: string, extractDir: string, skipOuterDir = true,
              tempDir = "", verbose = false) =
  ## Extracts the archive ``path`` into the specified ``directory``.
  ##
  ## `skipOuterDir` extracts subdir contents to `extractDir` if archive contains
  ## only one directory in the root
  ##
  ## `tempDir` is location to use for temporary extraction
  ##
  ## `verbose` if `true`, more verbose warnings are echoed to stdout
  var
    arch = archive_read_new()
    ext = archive_write_disk_new()
    entry: ptr archive_entry
    ret: cint
    currDir = getCurrentDir()
    tempDir = tempDir

  # Create a temporary directory for us to extract into. This allows us to
  # implement the `skipOuterDir` feature and ensures that no files are
  # extracted into the specified directory if the extraction fails mid-way.
  if tempDir.len == 0:
    tempDir = getTempDir() / "nimarchive-" & $((path & extractDir & $now()).hash().abs())
  removeDir(tempDir)
  createDir(tempDir)

  arch.archive_read_support_format_all().check(arch, verbose)

  arch.archive_read_support_compression_all().check(arch, verbose)

  ext.archive_write_disk_set_options(102).check(ext, verbose)

  ext.archive_write_disk_set_standard_lookup().check(ext, verbose)

  arch.archive_read_open_filename(path.cstring, 10240).check(arch, verbose)

  setCurrentDir(tempDir)
  defer:
    makeUserWritableRec(tempDir)
    removeDir(tempDir)
    setCurrentDir(currDir)

  while true:
    ret = arch.archive_read_next_header(addr entry)
    if ret == ARCHIVE_EOF:
      break
    ret.check(arch, verbose)

    ret = ext.archive_write_header(entry)
    when defined(Windows):
      if ret == ARCHIVE_FAILED:
        let
          ftype = entry.archive_entry_filetype().LA_MODE_T
        if ftype == AE_IFLNK:
          # Failed to extract symlink on Windows for some reason
          continue
    else:
      ret.check(ext, verbose)

    if entry.archive_entry_size() > 0:
      arch.copyData(ext, verbose).check(arch, verbose)

    ext.archive_write_finish_entry().check(ext, verbose)

  arch.archive_read_free().check(arch, verbose)
  ext.archive_write_free().check(ext, verbose)

  var
    srcDir = tempDir
  if skipOuterDir:
    for kind, path in walkDir(tempDir):
      if kind == pcFile:
        srcDir = tempDir
        break
      elif kind == pcDir:
        if srcDir == tempDir:
          srcDir = path
        else:
          srcDir = tempDir
          break

  setCurrentDir(currDir)
  createDir(extractDir)
  let permissions = getPermissionsRelativeRec(srcDir)
  makeUserWritableRec(srcDir)
  for kind, path in walkDir(srcDir, relative = true):
    if kind == pcFile:
      moveFile(srcDir / path, extractDir / path)
    elif kind == pcDir:
      moveDir(srcDir / path, extractDir / path)
  setPermissionsRec(extractDir, permissions)
