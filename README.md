Nimarchive is a [Nim](https://nim-lang.org/) wrapper for the [libarchive](https://github.com/libarchive/libarchive) library.

Nimarchive is distributed as a [Nimble](https://github.com/nim-lang/nimble) package and depends on [nimterop](https://github.com/nimterop/nimterop) to generate the wrappers.

__Installation__

Nimarchive can be installed via [Nimble](https://github.com/nim-lang/nimble):

```
> nimble install nimarchive
```

This will download and install nimarchive in the standard Nimble package location, typically ~/.nimble. Once installed, it can be imported into any Nim program.

[bzip2](https://sourceware.org/bzip2/), [liblzma](https://github.com/kobolabs/liblzma), [zlib](https://github.com/madler/zlib), [lz4](https://github.com/lz4/lz4), [expat](https://github.com/libexpat/libexpat) and [libiconv](https://www.gnu.org/software/libiconv/) are also downloaded since they are required dependencies.

On Linux, [acl](http://savannah.nongnu.org/projects/acl) and [Attr](https://savannah.nongnu.org/projects/attr/) are also downloaded.

__Usage__

Module documentation can be found [here](https://genotrance.github.io/nimarchive/nimarchive/archive.html).

```nim
import nimarchive

extract("tests/nimarchive.7z", "destDir")
```

The `extract()` API supports most popular archive formats and provides a generic interface. The `archive.h` functions are directly accessible as well by importing `nimarchive/archive`.

Refer to the ```tests``` directory for examples on how the library can be used. The libarchive [wiki](https://github.com/libarchive/libarchive/wiki) is also a good reference guide.

__Credits__

Nimarchive wraps the libarchive source code and all licensing terms of [libarchive](https://github.com/libarchive/libarchive/blob/master/COPYING) apply to the usage of this package. The [bzip2](https://github.com/genotrance/bzip2/blob/master/LICENSE), [liblzma](https://github.com/kobolabs/liblzma/blob/master/COPYING), [zlib](https://zlib.net/zlib_license.html), [expat](https://github.com/libexpat/libexpat/blob/master/expat/COPYING) and [libiconv](https://www.gnu.org/licenses/lgpl-2.1.html) terms also apply since they are dependencies.

On Linux, [acl](http://www.gnu.org/licenses/gpl-2.0.html) and [Attr](http://www.gnu.org/licenses/gpl-2.0.html) license terms also apply.

__Feedback__

Nimarchive is a work in progress and any feedback or suggestions are welcome. It is hosted on [GitHub](https://github.com/genotrance/nimarchive) with an MIT license so issues, forks and PRs are most appreciated.
