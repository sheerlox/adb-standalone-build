# adb-standalone-build

This project aims to build a standalone `adb` binary on Linux from downloaded sources (more trustable than source code copy-pasta and better maintainability).

The initial goal was to build the binary for the Raspberry Pi 4b (`aarch64` processor), but it should be architecture-independent since it builds everything from sources (developed on my `x86-64` laptop and then built without any issue on the RPi4b).

## Dependencies

- `cmake` (>= 3.10)
- `clang`
- `libstdc++-11-dev`
- `libgcc-11-dev`
- `libudev-dev`
- `libc6-dev`
- `golang-go` (to build BoringSSL)
- `pkg-config` (optional, improves BoringSSL build tests)
- `libunwind-dev` (optional, improves BoringSSL build tests)
- `autoconf` (to build libusb)
- `libtool` (to build libusb)

For Debian / Ubuntu:
```bash
sudo apt-get install cmake clang libstdc++-11-dev libgcc-11-dev libudev1 libudev-dev golang-go pkg-config libunwind-dev autoconf libtool
```

## Usage

Clone the repositories and install dependencies, then just:

```bash
cd adb-standalone-build/
make
make test
```

By default, messages are logged by each target (e.g. `Downloading adb source ...`, `Building boringssl ...`, etc...) and the commands' output is muted to follow the build more easily, but you can `tail -f error.log` to watch if anything goes wrong, or just comment the `SUPPRESS_OUTPUT` line in the root `Makefile` to get full commands output.

## Tested on

- `x86_64 Ubuntu 22.04 5.15.0-60-generic` / `clang 14` / `libstdc++-dev 11.3` / `libgcc-dev 11.3` / `cmake 3.22` / `go 1.18` / `autoconf 2.71` / `libtool 2.4`

## Screenshot

![image](https://user-images.githubusercontent.com/11234273/220209076-2fed1089-cc5e-4d88-b910-0c796a6dc77e.png)

## Credits

> Initially forked from [stevenrao/adb-proj](https://github.com/stevenrao/adb-proj).

This application uses Open Source components. You can find the source code of their open source projects along with license information below. We acknowledge and are grateful to these developers for their contributions to open source.

> Project: semver-tool https://github.com/fsaintjacques/semver-tool  
> Copyright 2023 François Saint-Jacques.  
> License (Apache License 2.0) https://github.com/fsaintjacques/semver-tool/blob/3.4.0/LICENSE  
