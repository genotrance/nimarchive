import algorithm, sequtils, tables, os

proc makeUserWritable(path: string) =
  inclFilePermissions(path, {fpUserExec, fpUserRead, fpUserWrite})

proc makeUserWritableRec*(dir: string) =
  makeUserWritable(dir)
  for kind, path in walkDir(dir):
    case kind
    of pcFile: makeUserWritable(path)
    of pcDir: makeUserWritableRec(path)
    else:
      discard

proc getPermissionsRec(dir: string): OrderedTable[string, set[FilePermission]] =
  for kind, path in walkDir(dir):
    case kind
    of pcFile:
      result[path] = getFilePermissions(path)
    of pcDir:
      for path, permissions in getPermissionsRec(path):
        result[path] = permissions
    else:
      discard

proc getPermissionsRelativeRec*(dir: string): OrderedTable[string, set[FilePermission]] =
  for path, permissions in getPermissionsRec(dir):
    result[relativePath(path, dir)] = permissions

proc setPermissionsRec*(dir: string, permissions: OrderedTable[string, set[FilePermission]]) =
  let paths = toSeq(permissions.keys)
  for path in paths.reversed:
    setFilePermissions(dir / path, permissions[path])
