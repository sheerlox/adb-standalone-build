# Methodolody

## Updating `libdepends`, `libadb` & `adb` source files list in `src/Makefile`

### libdepends
This one is really hacky: run `./utils/generate_libdepends_sources.sh`, replace `.???` with the correct source extensions and copy the result to the `libdepends_a_SOURCES_CXX` variable in `src/Makefile`.

There will be multiple entries to remove from that result (e.g. `android-base/endian.cpp` only exists as a header, `openssl/*` are loaded from the built libssl, `libusb/libusb.cpp` is loaded from the built `libusb-1.0.a` and `arpa/inet.h` / `netinet/in.h` are headers provided by the standard C library).

### libadb

In `src/adb/Android.bp`, find `libadbd_core` library declaration (look at the `srcs` property).
Then update all `bp_libadb*_SOURCES` variables in `src/Makefile`.

*Note: don't account for the `daemon/*` files as they are destined to the Android devices.*

### adb

In `src/adb/Android.bp`, find `adb` binary declaration (look at the `srcs` property).
Then update the `adb_SOURCES` variable in `src/Makefile`.


## Adding a missing header

When getting a missing header error while compiling, e.g.:
```
In file included from adb/adb.cpp:19:
adb/adb.cpp:48:10: fatal error: 'build/version.h' file not found
#include <build/version.h>
         ^~~~~~~~~~~~~~~~~
1 error generated.
make: *** [Makefile:185: adb/adb.o] Error 1
```

- navigate to https://cs.android.com/
- search the missing header (e.g. `build/version.h`)
- find the lib that provides the missing header (e.g. `build/soong/cc/libbuildversion/include/build/version.h`)
- add a download target for that header in the root `Makefile` (e.g. see `download_build_headers` target)
