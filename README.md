# adb-standalone-build

This project aims to build a standalone `adb` binary on Linux from downloaded sources (more trustable than source code copy-pasta and better maintainability).

The initial goal was to build the binary for the Raspberry Pi 4b (`aarch64` processor), but it should be architecture-independent since it builds everything from sources (developed on my `x86-64` laptop and then built without any issue on the RPi4b).

## Requirements

- `clang`
- `cmake` (to build Protobuf & BoringSSL)
- `golang-go` (to build BoringSSL)
- `libunwind-dev` (optional, to test BoringSSL build)
- `autoconf` (to build libusb)
- `libtool` (to build libusb)
- `libudev1` (to build libusb)
- `libudev-dev` (to build libusb)

For Debian / Ubuntu:
```bash
sudo apt-get install clang cmake golang-go libunwind-dev autoconf libtool libudev1 libudev-dev
```

## Tested on

- `x86_64 Ubuntu 22.04 5.15.0-60-generic`

## Credits

> Initially forked from [stevenrao/adb-proj](https://github.com/stevenrao/adb-proj).

This application uses Open Source components. You can find the source code of their open source projects along with license information below. We acknowledge and are grateful to these developers for their contributions to open source.

> Project: semver-tool https://github.com/fsaintjacques/semver-tool  
> Copyright 2023 François Saint-Jacques.  
> License (Apache License 2.0) https://github.com/fsaintjacques/semver-tool/blob/3.4.0/LICENSE  
