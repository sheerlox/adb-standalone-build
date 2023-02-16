# adb-arm-build

This project aims to build standalone `adb` for the arm/arm64 platform from downloaded sources (so sources are trustable and it can be easily updated).

## Requirements

- `golang-go` (to build BoringSSL)
- `libunwind-dev` (optional, to test BoringSSL build)
- `autoconf` (to build libusb)
- `libtool` (to build libusb)
- `libudev1` (to build libusb)
- `libudev-dev` (to build libusb)

For Debian / Ubuntu:
```bash
sudo apt-get install golang-go libunwind-dev autoconf libtool libudev1 libudev-dev
```

## Resources
- https://github.com/stevenrao/adb-proj
- https://github.com/bonnyfone/adb-arm
- https://github.com/prife/adb
- https://src.fedoraproject.org/rpms/android-tools/blob/rawhide/f/generate_build.rb
