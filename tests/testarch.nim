import nimarchive/archive
import nimarchive/archive_entry

var arch = archive_read_new()
if archive_read_support_format_7zip(arch) != ARCHIVE_OK:
  echo "7zip not supported"
  quit(1)

if archive_read_open_filename(arch, "tests\\nimarchive.7z", 10240) != ARCHIVE_OK:
  echo archive_error_string(arch)
  quit(1)

var arch_entry: ptr archive_entry

while archive_read_next_header(arch, addr arch_entry) == ARCHIVE_OK:
  assert archive_entry_pathname(arch_entry) == "nimarchive.cfg"
  assert archive_read_data_skip(arch) == 0

if archive_read_free(arch) != ARCHIVE_OK:
  echo "Free failed"
  quit(1)
