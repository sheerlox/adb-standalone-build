# adb-arm-build

This project aims to build standalone `adb` for the arm/arm64 platform from downloaded sources (so sources are trustable and it can be easily updated).

## Requirements

- `cmake` (to build Protobuf & BoringSSL)
- `golang-go` (to build BoringSSL)
- `libunwind-dev` (optional, to test BoringSSL build)
- `autoconf` (to build libusb)
- `libtool` (to build libusb)
- `libudev1` (to build libusb)
- `libudev-dev` (to build libusb)

For Debian / Ubuntu:
```bash
sudo apt-get install cmake golang-go libunwind-dev autoconf libtool libudev1 libudev-dev
```

## Resources
- https://github.com/stevenrao/adb-proj
- https://github.com/bonnyfone/adb-arm
- https://github.com/prife/adb
- https://src.fedoraproject.org/rpms/android-tools/blob/rawhide/f/generate_build.rb

## Credits

Initially forked from https://github.com/stevenrao/adb-proj.

This application uses Open Source components. You can find the source code of their open source projects along with license information below. We acknowledge and are grateful to these developers for their contributions to open source.

> Project: semver-tool https://github.com/fsaintjacques/semver-tool  
> Copyright 2023 François Saint-Jacques.  
> License (Apache License 2.0) https://github.com/fsaintjacques/semver-tool/blob/3.4.0/LICENSE  
