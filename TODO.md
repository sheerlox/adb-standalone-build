# TODO

- [X] move `compile_proto_files` to `src/Makefile` as the targets cannot be resolved on first run (`.proto` files aren't present yet)
- [X] move compiled libraries / binaries from root Makefile to `$(OUT_DIR)` for easier referencing
- [X] build and run C++ `adb` tests (GoogleTest)
- [ ] build and run C++ `adb/crypto`, `adb/pairing_auth`, `adb/pairing_connection` & `adb/tls` tests (GoogleTest)
- [ ] find out why `adb_listeners_test.cpp` and `transport_test.cpp` result in Segmentation fault
- [ ] boringssl: only build and test libssl & libcrypto
- [ ] reduce binary size ?
- [ ] also build `fastboot` ?
