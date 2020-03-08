Nimarchive is a [Nim](https://nim-lang.org/) wrapper for the [libarchive](https://github.com/libarchive/libarchive) library.

Nimarchive is distributed as a [Nimble](https://github.com/nim-lang/nimble) package and depends on [nimterop](https://github.com/nimterop/nimterop) to generate the wrappers. The libarchive source code is downloaded using Git so having ```git``` in the path is required.

__Installation__

Nimarchive can be installed via [Nimble](https://github.com/nim-lang/nimble):

```
> nimble install nimarchive
```

This will download and install nimarchive in the standard Nimble package location, typically ~/.nimble. Once installed, it can be imported into any Nim program.

[liblzma](https://github.com/kobolabs/liblzma) and [zlib](https://github.com/madler/zlib) are also downloaded since they are required dependencies.

On Windows, `cmake` and `git bash` are required for a successful build. In addition, `git bash` should be in location that does not have spaces in the path without which `cmake` fails.

__Usage__

Module documentation can be found [here](https://genotrance.github.io/nimarchive/theindex.html).

```nim
import nimarchive

extract("tests/nimarchive.7z", "destDir")
```

The `extract()` API supports most popular archive formats and provides a generic interface. The `archive.h` functions are directly accessible as well by importing `nimarchive/archive`.

Refer to the ```tests``` directory for examples on how the library can be used. The libarchive [wiki](https://github.com/libarchive/libarchive/wiki) is also a good reference guide.

__Credits__

Nimarchive wraps the libarchive source code and all licensing terms of [libarchive](https://github.com/libarchive/libarchive/blob/master/COPYING) apply to the usage of this package. The [liblzma](https://github.com/kobolabs/liblzma/blob/master/COPYING) and [zlib](https://zlib.net/zlib_license.html) terms also apply since they are dependencies.

__Feedback__

Nimarchive is a work in progress and any feedback or suggestions are welcome. It is hosted on [GitHub](https://github.com/genotrance/nimarchive) with an MIT license so issues, forks and PRs are most appreciated.
