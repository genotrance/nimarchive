Nimarchive is a [Nim](https://nim-lang.org/) wrapper for the [libarchive](https://github.com/libarchive/libarchive) library.

Nimarchive is distributed as a [Nimble](https://github.com/nim-lang/nimble) package and depends on [nimgen](https://github.com/genotrance/nimgen) and [c2nim](https://github.com/nim-lang/c2nim/) to generate the wrappers. The libarchive source code is downloaded using Git so having ```git``` in the path is required.

__Installation__

Nimarchive can be installed via [Nimble](https://github.com/nim-lang/nimble):

```
> nimble install nimgen

> git clone https://github.com/genotrance/nimarchive
> cd nimarchive
> nimble install
```

This will download, wrap and install nimarchive in the standard Nimble package location, typically ~/.nimble. Once installed, it can be imported into any Nim program.

__Usage__

Module documentation can be found [here](http://nimgen.genotrance.com/nimarchive).

```nim
import os

import nimarchive/archive
import nimarchive/archive_entry

var arch = archive_read_new()
if archive_read_support_format_7zip(arch) != ARCHIVE_OK:
  echo "7zip not supported"
  quit(1)

if archive_read_open_filename(arch, "tests"/"nimarchive.7z", 10240) != ARCHIVE_OK:
  echo archive_error_string(arch)
  quit(1)

var arch_entry: ptr archive_entry

while archive_read_next_header(arch, addr arch_entry) == ARCHIVE_OK:
  assert archive_entry_pathname(arch_entry) == "nimarchive.cfg"
  assert archive_read_data_skip(arch) == 0

if archive_read_free(arch) != ARCHIVE_OK:
  echo "Free failed"
  quit(1)
```

The archive.h functions are directly accessible at this time. A higher level API is still TBD.

Refer to the ```tests``` directory for examples on how the library can be used.

__Credits__

Nimarchive wraps the libarchive source code and all licensing terms of [libarchive](https://github.com/libarchive/libarchive/blob/master/COPYING) apply to the usage of this package.

Credits go out to [c2nim](https://github.com/nim-lang/c2nim/) as well without which this package would be greatly limited in its abilities.

__Feedback__

Nimarchive is a work in progress and any feedback or suggestions are welcome. It is hosted on [GitHub](https://github.com/genotrance/nimarchive) with an MIT license so issues, forks and PRs are most appreciated.
