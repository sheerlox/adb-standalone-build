# TODO

- [X] move `compile_proto_files` to `src/Makefile` as the targets cannot be resolved on first run (`.proto` files aren't present yet)
- [X] move compiled libraries / binaries from root Makefile to `$(OUT_DIR)` for easier referencing
- [ ] compile and run C++ `adb` tests (GoogleTest)
- [ ] reduce binary size
- [ ] also build `fastboot` ?
- [ ] boringssl: only build and test libssl & libcrypto
