SHELL := /bin/bash

PLATFORM_TOOLS_VERSION := 31.0.0
PLATFORM_TOOLS_REF := platform-tools-$(PLATFORM_TOOLS_VERSION)

# comment out the following line to get full commands output
SUPPRESS_OUTPUT := >/dev/null 2>>error.log

STAMPS_DIR := .stamps
SOURCE_DIR := $(abspath src)
DEPENDS_DIR := $(SOURCE_DIR)/depends
INCLUDES_DIR := $(SOURCE_DIR)/includes
EXTERNAL_DIR := $(SOURCE_DIR)/external
OUT_DIR := $(abspath out)
LIBS_DIR := $(OUT_DIR)/.libs

NPROCS := $(shell grep -c ^processor /proc/cpuinfo)

# export variables to make them available to the child Makefile
export DEPENDS_DIR
export INCLUDES_DIR
export EXTERNAL_DIR
export OUT_DIR
export LIBS_DIR

# create working directories if they don't exist
ifneq ($(STAMPS_DIR), $(wildcard $(STAMPS_DIR)))
  $(shell mkdir -p $(STAMPS_DIR))
endif
ifneq ($(DEPENDS_DIR), $(wildcard $(DEPENDS_DIR)))
  $(shell mkdir -p $(DEPENDS_DIR))
endif
ifneq ($(INCLUDES_DIR), $(wildcard $(INCLUDES_DIR)))
  $(shell mkdir -p $(INCLUDES_DIR))
endif
ifneq ($(EXTERNAL_DIR), $(wildcard $(EXTERNAL_DIR)))
  $(shell mkdir -p $(EXTERNAL_DIR))
endif
ifneq ($(LIBS_DIR), $(wildcard $(LIBS_DIR)))
  $(shell mkdir -p $(LIBS_DIR))
endif
$(shell rm error.log && touch error.log)

$(info Checking if Platform Tools version $(PLATFORM_TOOLS_VERSION) exists...)
VERSION_EXISTS := $(shell git ls-remote --exit-code --tags https://android.googlesource.com/platform/manifest refs/tags/$(PLATFORM_TOOLS_REF) >/dev/null 2>&1; echo $$?)
ifneq ($(VERSION_EXISTS),0)
	AVAILABLE_VERSION := $(shell git ls-remote --tags https://android.googlesource.com/platform/manifest refs/tags/platform-tools-* | grep -v "\^{}" | awk '{ORS=", "} {gsub("refs/tags/platform-tools-", ""); print $$2}')
  $(error Platform Tools version $(PLATFORM_TOOLS_VERSION) doesn't exist. Available versions: $(AVAILABLE_VERSION))
else
  $(info Platform Tools version $(PLATFORM_TOOLS_VERSION) found!)
endif

all: make_adb

make_adb: all_download_source all_download_external all_download_headers all_patch_source all_build_external $(OUT_DIR)/bin/adb
$(OUT_DIR)/bin/adb:
	@echo "Building adb ..."
	@cd $(SOURCE_DIR) && make

test: make_adb
	@export PATH=$(OUT_DIR)/bin:$${PATH}; \
		python $(SOURCE_DIR)/adb/test_adb.py

########################
#   DOWNLOAD SOURCE    #
########################
all_download_source: download_adb_source download_androidfw_source download_libbase_source download_libcutils_source download_libcrypto_utils_source \
	download_libutils_source download_liblog_source download_libbuildversion_source download_libziparchive_source download_incfs_util_source \
	download_diagnose_usb_source download_mdnssd_source

download_adb_source: $(SOURCE_DIR)/adb
$(SOURCE_DIR)/adb:
	@echo "Downloading adb source ..."
	@git clone https://android.googlesource.com/platform/packages/modules/adb --branch $(PLATFORM_TOOLS_REF) $(SOURCE_DIR)/adb $(SUPPRESS_OUTPUT)

download_androidfw_source: $(DEPENDS_DIR)/androidfw
$(DEPENDS_DIR)/androidfw:
	@echo "Downloading androidfw source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/frameworks/base $(PLATFORM_TOOLS_REF) libs/androidfw/ $(DEPENDS_DIR)/androidfw/ $(SUPPRESS_OUTPUT)

download_libbase_source: $(DEPENDS_DIR)/base
$(DEPENDS_DIR)/base:
	@echo "Downloading libbase source ..."
	@git clone https://android.googlesource.com/platform/system/libbase --single-branch --branch $(PLATFORM_TOOLS_REF) $(DEPENDS_DIR)/base $(SUPPRESS_OUTPUT)
	@rm -rf $(DEPENDS_DIR)/base/.git

download_libcutils_source: $(DEPENDS_DIR)/cutils
$(DEPENDS_DIR)/cutils:
	@echo "Downloading libcutils source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) libcutils $(DEPENDS_DIR)/cutils $(SUPPRESS_OUTPUT)

download_libcrypto_utils_source: $(DEPENDS_DIR)/crypto_utils
$(DEPENDS_DIR)/crypto_utils:
	@echo "Downloading libcrypto_utils source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) libcrypto_utils $(DEPENDS_DIR)/crypto_utils $(SUPPRESS_OUTPUT)

download_libutils_source: $(DEPENDS_DIR)/utils
$(DEPENDS_DIR)/utils:
	@echo "Downloading libutils source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) libutils $(DEPENDS_DIR)/utils $(SUPPRESS_OUTPUT)

download_liblog_source: $(DEPENDS_DIR)/log
$(DEPENDS_DIR)/log:
	@echo "Downloading liblog source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/logging $(PLATFORM_TOOLS_REF) liblog $(DEPENDS_DIR)/log $(SUPPRESS_OUTPUT)

download_libbuildversion_source: $(DEPENDS_DIR)/buildversion
$(DEPENDS_DIR)/buildversion:
	@echo "Downloading libbuildversion source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/build/soong $(PLATFORM_TOOLS_REF) cc/libbuildversion/ $(DEPENDS_DIR)/buildversion/ $(SUPPRESS_OUTPUT)

download_libziparchive_source: $(DEPENDS_DIR)/libziparchive
$(DEPENDS_DIR)/libziparchive:
	@echo "Downloading libziparchive source ..."
# fix depends/libziparchive/...: error: calling a private constructor of class '...' errors
# if $PLATFORM_TOOLS_VERSION < 32.0.0
	@if [ $$(./utils/semver.sh compare $(PLATFORM_TOOLS_VERSION) 32.0.0) -eq -1 ]; \
		then \
			git clone https://android.googlesource.com/platform/system/libziparchive --single-branch --branch platform-tools-32.0.0 $(DEPENDS_DIR)/libziparchive $(SUPPRESS_OUTPUT); \
		else \
			git clone https://android.googlesource.com/platform/system/libziparchive --single-branch --branch $(PLATFORM_TOOLS_REF) $(DEPENDS_DIR)/libziparchive $(SUPPRESS_OUTPUT); \
		fi
	@rm -rf $(DEPENDS_DIR)/libziparchive/.git

download_incfs_util_source: $(DEPENDS_DIR)/incfs_util
$(DEPENDS_DIR)/incfs_util:
	@echo "Downloading incfs_util source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/incremental_delivery $(PLATFORM_TOOLS_REF) incfs/util $(DEPENDS_DIR)/incfs_util/ $(SUPPRESS_OUTPUT)

download_diagnose_usb_source: $(DEPENDS_DIR)/diagnose_usb
$(DEPENDS_DIR)/diagnose_usb:
	@echo "Downloading diagnose_usb source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) diagnose_usb $(DEPENDS_DIR)/diagnose_usb $(SUPPRESS_OUTPUT)

download_mdnssd_source: $(DEPENDS_DIR)/mdnssd
$(DEPENDS_DIR)/mdnssd:
	@echo "Downloading mdnssd source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/mdnsresponder $(PLATFORM_TOOLS_REF) mDNSShared $(DEPENDS_DIR)/mdnssd $(SUPPRESS_OUTPUT)

########################
#  DOWNLOAD EXTERNAL   #
########################
all_download_external: download_zlib_external download_protobuf_external download_boringssl_external download_libusb_external	download_lz4_external \
	download_zstd_external download_brotli_external

download_zlib_external: $(EXTERNAL_DIR)/zlib
$(EXTERNAL_DIR)/zlib:
	@echo "Downloading zlib source ..."
	@git clone https://github.com/madler/zlib --single-branch --branch v$$(./utils/get_zlib_version.sh $(PLATFORM_TOOLS_VERSION)) $(EXTERNAL_DIR)/zlib $(SUPPRESS_OUTPUT)

download_protobuf_external: $(EXTERNAL_DIR)/protobuf
$(EXTERNAL_DIR)/protobuf:
	@echo "Downloading protobuf source ..."
	@git clone https://github.com/protocolbuffers/protobuf --recurse-submodules --single-branch --branch v$$(./utils/get_protobuf_version.sh $(PLATFORM_TOOLS_VERSION)) $(EXTERNAL_DIR)/protobuf $(SUPPRESS_OUTPUT)
	@rm -rf $(EXTERNAL_DIR)/protobuf/**/.git

download_boringssl_external: $(EXTERNAL_DIR)/boringssl
$(EXTERNAL_DIR)/boringssl:
	@echo "Downloading boringssl source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/boringssl $(PLATFORM_TOOLS_REF) src $(EXTERNAL_DIR)/boringssl $(SUPPRESS_OUTPUT)

download_libusb_external: $(EXTERNAL_DIR)/libusb
$(EXTERNAL_DIR)/libusb:
	@echo "Downloading libusb source ..."
	@git clone https://android.googlesource.com/platform/external/libusb --single-branch --branch $(PLATFORM_TOOLS_REF) $(EXTERNAL_DIR)/libusb/ $(SUPPRESS_OUTPUT)

download_lz4_external: $(EXTERNAL_DIR)/lz4
$(EXTERNAL_DIR)/lz4:
	@echo "Downloading lz4 source ..."
	@git clone https://github.com/lz4/lz4 --single-branch --branch v$$(./utils/get_lz4_version.sh $(PLATFORM_TOOLS_VERSION)) $(EXTERNAL_DIR)/lz4 $(SUPPRESS_OUTPUT)
	@rm -rf $(EXTERNAL_DIR)/lz4/.git

download_zstd_external: $(EXTERNAL_DIR)/zstd
$(EXTERNAL_DIR)/zstd:
	@echo "Downloading zstd source ..."
	@git clone https://github.com/facebook/zstd --single-branch --branch v$$(./utils/get_zstd_version.sh $(PLATFORM_TOOLS_VERSION)) $(EXTERNAL_DIR)/zstd $(SUPPRESS_OUTPUT)
	@rm -rf $(EXTERNAL_DIR)/zstd/.git

download_brotli_external: $(EXTERNAL_DIR)/brotli
$(EXTERNAL_DIR)/brotli:
	@echo "Downloading brotli ..."
	@git clone https://android.googlesource.com/platform/external/brotli --single-branch --branch $(PLATFORM_TOOLS_REF) $(EXTERNAL_DIR)/brotli/ $(SUPPRESS_OUTPUT)

########################
#     PATCH SOURCE     #
########################
all_patch_source: patch_adb_source patch_incfs_util_source patch_buildversion_source

patch_adb_source: $(STAMPS_DIR)/patch_adb_source
$(STAMPS_DIR)/patch_adb_source:
	@echo "Patching adb source ..."
# if 31.0.0 >= $PLATFORM_TOOLS_VERSION < 34.0.0
	@if [ $$(./utils/semver.sh compare 31.0.0 $(PLATFORM_TOOLS_VERSION)) -le 0 ] && [ $$(./utils/semver.sh compare $(PLATFORM_TOOLS_VERSION) 34.0.0) -eq -1 ]; \
		then \
			sed -i '/^namespace adb {/i #include <string.h>\n' $(SOURCE_DIR)/adb/crypto/x509_generator.cpp; \
		fi
# if 31.0.0 >= $PLATFORM_TOOLS_VERSION < 33.0.4
	@if [ $$(./utils/semver.sh compare 31.0.0 $(PLATFORM_TOOLS_VERSION)) -le 0 ] && [ $$(./utils/semver.sh compare $(PLATFORM_TOOLS_VERSION) 33.0.4) -eq -1 ]; \
		then \
			sed -i '/^using namespace adb::pairing;/i #include <string.h>\n' $(SOURCE_DIR)/adb/pairing_auth/pairing_auth.cpp; \
			sed -i '/^namespace adb {/i #include <string.h>\n' $(SOURCE_DIR)/adb/pairing_auth/aes_128_gcm.cpp; \
		fi
	@touch $(STAMPS_DIR)/patch_adb_source

patch_incfs_util_source: $(STAMPS_DIR)/patch_incfs_util_source
$(STAMPS_DIR)/patch_incfs_util_source:
	@echo "Patching incfs_util source ..."
# if 30.0.5 >= $PLATFORM_TOOLS_VERSION < 32.0.0
	@if [ $$(./utils/semver.sh compare 30.0.5 $(PLATFORM_TOOLS_VERSION)) -le 0 ] && [ $$(./utils/semver.sh compare $(PLATFORM_TOOLS_VERSION) 32.0.0) -eq -1 ]; \
		then \
			sed -i '/^#include <vector>/i #include <atomic>' $(DEPENDS_DIR)/incfs_util/include/util/map_ptr.h; \
		fi
	@touch $(STAMPS_DIR)/patch_incfs_util_source

patch_buildversion_source: $(STAMPS_DIR)/patch_buildversion_source
$(STAMPS_DIR)/patch_buildversion_source:
	@echo "Patching buildversion source ..."
	@sed -i "s/SOONG BUILD NUMBER PLACEHOLDER/sheerlox\/adb-standalone-build/g" $(DEPENDS_DIR)/buildversion/libbuildversion.cpp
	@touch $(STAMPS_DIR)/patch_buildversion_source

########################
#   DOWNLOAD HEADERS   #
########################
all_download_headers: download_android_headers download_adbd_auth_headers	download_fmtlib_headers download_system_headers download_gtest_headers \
	generate_pt_version_header generate_deployagent_includes

download_android_headers: $(INCLUDES_DIR)/android
$(INCLUDES_DIR)/android:
	@echo "Downloading android headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/logging $(PLATFORM_TOOLS_REF) liblog/include/android/ $(INCLUDES_DIR)/android/ $(SUPPRESS_OUTPUT)
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/frameworks/native $(PLATFORM_TOOLS_REF) include/android/* $(INCLUDES_DIR)/android/ $(SUPPRESS_OUTPUT)

download_adbd_auth_headers: $(INCLUDES_DIR)/adbd_auth.h
$(INCLUDES_DIR)/adbd_auth.h:
	@echo "Downloading adbd_auth headers ..."
	@curl https://android.googlesource.com/platform/frameworks/native/+/refs/tags/$(PLATFORM_TOOLS_REF)/libs/adbd_auth/include/adbd_auth.h?format=text -s | base64 -d > $(INCLUDES_DIR)/adbd_auth.h

download_fmtlib_headers: $(INCLUDES_DIR)/fmt
$(INCLUDES_DIR)/fmt:
	@echo "Downloading fmtlib headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/fmtlib $(PLATFORM_TOOLS_REF) include/fmt/ $(INCLUDES_DIR)/fmt/ $(SUPPRESS_OUTPUT)

download_system_headers: $(INCLUDES_DIR)/system
$(INCLUDES_DIR)/system:
	@echo "Downloading system headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) libsystem/include/system/ $(INCLUDES_DIR)/system/ $(SUPPRESS_OUTPUT)

download_gtest_headers: $(INCLUDES_DIR)/gtest
$(INCLUDES_DIR)/gtest:
	@echo "Downloading gtest headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/googletest $(PLATFORM_TOOLS_REF) googletest/include/gtest/ $(INCLUDES_DIR)/gtest/ $(SUPPRESS_OUTPUT)

generate_pt_version_header: $(INCLUDES_DIR)/platform_tools_version.h
$(INCLUDES_DIR)/platform_tools_version.h:
	@echo "Generating platform tools version header ..."
	@echo '#define PLATFORM_TOOLS_VERSION "$(PLATFORM_TOOLS_VERSION)"' > $(INCLUDES_DIR)/platform_tools_version.h

generate_deployagent_includes: $(SOURCE_DIR)/adb/deployagent.inc $(SOURCE_DIR)/adb/deployagentscript.inc
$(SOURCE_DIR)/adb/deployagent.inc:
$(SOURCE_DIR)/adb/deployagentscript.inc:
	@echo "Generating deployagent includes ..."
	@(echo 'unsigned char kDeployAgent[] = {' && xxd -i <$(SOURCE_DIR)/adb/fastdeploy/deployagent/src/com/android/fastdeploy/DeployAgent.java && echo '};') > $(SOURCE_DIR)/adb/deployagent.inc
	@(echo 'unsigned char kDeployAgentScript[] = {' && xxd -i <$(SOURCE_DIR)/adb/fastdeploy/deployagent/src/com/android/fastdeploy/DeployAgent.java && echo '};') > $(SOURCE_DIR)/adb/deployagentscript.inc

########################
#        BUILD         #
########################
all_build_external: build_zlib_external build_protobuf_external build_libusb_external build_boringssl_external build_liblz4_external build_libzstd_external build_brotli_external

build_zlib_external: download_zlib_external $(LIBS_DIR)/libz.a
$(LIBS_DIR)/libz.a:
	@echo "Building zlib ..."
	@cd $(EXTERNAL_DIR)/zlib; \
		./configure $(SUPPRESS_OUTPUT); \
		make $(SUPPRESS_OUTPUT); \
		cp libz.a $(LIBS_DIR)

build_protobuf_external: download_protobuf_external build_zlib_external $(LIBS_DIR)/protoc $(LIBS_DIR)/libprotobuf.a
$(LIBS_DIR)/protoc:
$(LIBS_DIR)/libprotobuf.a:
	@echo "Building protobuf ..."
	@cd $(EXTERNAL_DIR)/protobuf; \
		cmake ./cmake -DCMAKE_CXX_STANDARD=20 -DZLIB_LIBRARY=$(EXTERNAL_DIR)/zlib/libz.a -DZLIB_INCLUDE_DIR=$(EXTERNAL_DIR)/zlib/ $(SUPPRESS_OUTPUT); \
		cmake --build . -j$(NPROCS) $(SUPPRESS_OUTPUT); \
		echo "Testing protobuf build ..."; \
		cmake --build . --target check $(SUPPRESS_OUTPUT); \
		cp protoc libprotobuf.a $(LIBS_DIR)

build_libusb_external: download_libusb_external $(LIBS_DIR)/libusb-1.0.a
$(LIBS_DIR)/libusb-1.0.a:
	@echo "Building libusb ..."
	@cd $(EXTERNAL_DIR)/libusb; \
		./autogen.sh --enable-static --disable-shared $(SUPPRESS_OUTPUT); \
		make $(SUPPRESS_OUTPUT); \
		cp libusb/.libs/libusb-1.0.a $(LIBS_DIR)

build_boringssl_external: download_boringssl_external $(LIBS_DIR)/libcrypto.a $(LIBS_DIR)/libssl.a
$(LIBS_DIR)/libcrypto.a:
$(LIBS_DIR)/libssl.a:
	@echo "Building boringssl ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/googletest $(PLATFORM_TOOLS_REF) googletest/ $(EXTERNAL_DIR)/boringssl/third_party/googletest/ $(SUPPRESS_OUTPUT); \
		sed -i 's/-Wformat=2 //' $(EXTERNAL_DIR)/boringssl/CMakeLists.txt; \
		mkdir -p $(EXTERNAL_DIR)/boringssl/build; \
		cd $(EXTERNAL_DIR)/boringssl/build; \
		CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake .. $(SUPPRESS_OUTPUT); \
		make $(SUPPRESS_OUTPUT); \
		echo "Testing boringssl build ..."; \
		go run $(EXTERNAL_DIR)/boringssl/util/all_tests.go $(SUPPRESS_OUTPUT); \
		cd $(EXTERNAL_DIR)/boringssl/ssl/test/runner && go test $(SUPPRESS_OUTPUT); \
		cp $(EXTERNAL_DIR)/boringssl/build/ssl/libssl.a $(EXTERNAL_DIR)/boringssl/build/crypto/libcrypto.a $(LIBS_DIR)

build_liblz4_external: download_lz4_external $(LIBS_DIR)/liblz4.a
$(LIBS_DIR)/liblz4.a:
	@echo "Building lz4 ..."
	@cd $(EXTERNAL_DIR)/lz4; \
		make $(SUPPRESS_OUTPUT); \
		cp lib/liblz4.a $(LIBS_DIR)

build_libzstd_external: download_zstd_external $(LIBS_DIR)/libzstd.a
$(LIBS_DIR)/libzstd.a:
	@echo "Building libzstd ..."
	@cd $(EXTERNAL_DIR)/zstd; \
		make lib $(SUPPRESS_OUTPUT); \
		cp lib/libzstd.a $(LIBS_DIR)

build_brotli_external: download_brotli_external $(LIBS_DIR)/libbrotlicommon-static.a $(LIBS_DIR)/libbrotlidec-static.a $(LIBS_DIR)/libbrotlienc-static.a
$(LIBS_DIR)/libbrotlicommon-static.a:
$(LIBS_DIR)/libbrotlidec-static.a:
$(LIBS_DIR)/libbrotlienc-static.a:
	@echo "Building brotli ..."
	@cd $(EXTERNAL_DIR)/brotli; \
		./configure-cmake --disable-debug $(SUPPRESS_OUTPUT); \
		make $(SUPPRESS_OUTPUT); \
		echo "Testing brotli build ..."; \
		make test $(SUPPRESS_OUTPUT); \
		cp libbrotlienc-static.a libbrotlidec-static.a libbrotlicommon-static.a $(LIBS_DIR)

########################
#         MISC         #
########################
clean_all: clean_build clean_sources

clean_build:
	@cd $(SOURCE_DIR) && make clean

clean_sources:
	@rm -rf $(SOURCE_DIR)/adb $(STAMPS_DIR) $(DEPENDS_DIR) $(INCLUDES_DIR) $(EXTERNAL_DIR) $(OUT_DIR)
