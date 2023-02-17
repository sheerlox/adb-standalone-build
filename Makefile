SHELL := /bin/bash

PLATFORM_TOOLS_VERSION := 31.0.0
PLATFORM_TOOLS_REF := platform-tools-$(PLATFORM_TOOLS_VERSION)

STAMPS_DIR := .stamps
SOURCE_DIR := $(abspath src)
DEPENDS_DIR := $(SOURCE_DIR)/depends
INCLUDES_DIR := $(SOURCE_DIR)/includes
EXTERNAL_DIR := $(SOURCE_DIR)/external

NPROCS := $(shell grep -c ^processor /proc/cpuinfo)

# comment out the following line to get full commands output
SUPPRESS_OUTPUT := >/dev/null 2>&1

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

$(info Checking if Platform Tools version $(PLATFORM_TOOLS_VERSION) exists...)
VERSION_EXISTS := $(shell git ls-remote --exit-code --tags https://android.googlesource.com/platform/manifest refs/tags/$(PLATFORM_TOOLS_REF) >/dev/null 2>&1; echo $$?)
ifneq ($(VERSION_EXISTS),0)
	AVAILABLE_VERSION := $(shell git ls-remote --tags https://android.googlesource.com/platform/system/incremental_delivery refs/tags/platform-tools-* | grep -v "\^{}" | awk '{ORS=", "} {gsub("refs/tags/platform-tools-", ""); print $$2}')
  $(error Platform Tools version $(PLATFORM_TOOLS_VERSION) doesn't exist. Available versions: $(AVAILABLE_VERSION))
else
  $(info Platform Tools version $(PLATFORM_TOOLS_VERSION) found!)
endif

all: all_download_source all_patch_source all_download_headers all_download_external all_build all_compile

########################
#   DOWNLOAD SOURCE    #
########################
all_download_source: download_adb_source download_androidfw_source download_libbase_source download_libcutils_source download_libcrypto_utils_source \
	download_libutils_source download_liblog_source download_libbuildversion_source download_incfs_util_source download_diagnose_usb_source

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

download_incfs_util_source: $(DEPENDS_DIR)/incfs_util
$(DEPENDS_DIR)/incfs_util:
	@echo "Downloading incfs_util source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/incremental_delivery $(PLATFORM_TOOLS_REF) incfs/util $(DEPENDS_DIR)/incfs_util/ $(SUPPRESS_OUTPUT)

download_diagnose_usb_source: $(DEPENDS_DIR)/diagnose_usb
$(DEPENDS_DIR)/diagnose_usb:
	@echo "Downloading diagnose_usb source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) diagnose_usb $(DEPENDS_DIR)/diagnose_usb $(SUPPRESS_OUTPUT)

########################
#     PATCH SOURCE     #
########################
all_patch_source: patch_adb_source patch_incfs_util_source

patch_adb_source: $(STAMPS_DIR)/patch_adb_source
$(STAMPS_DIR)/patch_adb_source:
	@echo "Patching adb source ..."
# if 31.0.0 >= $PLATFORM_TOOLS_VERSION < 34.0.0
	@if [ $(shell ./utils/semver.sh compare 31.0.0 $(PLATFORM_TOOLS_VERSION)) -le 0 ] && [ $(shell ./utils/semver.sh compare $(PLATFORM_TOOLS_VERSION) 34.0.0) -eq -1 ]; \
		then \
			sed -i '/^namespace adb.*/i #include <string.h>\n' $(SOURCE_DIR)/adb/crypto/x509_generator.cpp; \
		fi
	@touch $(STAMPS_DIR)/patch_adb_source

patch_incfs_util_source: $(STAMPS_DIR)/patch_incfs_util_source
$(STAMPS_DIR)/patch_incfs_util_source:
	@echo "Patching incfs_util source ..."
# if 30.0.5 >= $PLATFORM_TOOLS_VERSION < 32.0.0
	@if [ $(shell ./utils/semver.sh compare 30.0.5 $(PLATFORM_TOOLS_VERSION)) -le 0 ] && [ $(shell ./utils/semver.sh compare $(PLATFORM_TOOLS_VERSION) 32.0.0) -eq -1 ]; \
		then \
			sed -i '/^#include <vector>/i #include <atomic>' $(DEPENDS_DIR)/incfs_util/include/util/map_ptr.h; \
		fi
	@touch $(STAMPS_DIR)/patch_incfs_util_source

########################
#   DOWNLOAD HEADERS   #
########################
all_download_headers: download_android_headers download_adbd_auth_headers download_brotli_headers \
	download_fmtlib_headers download_system_headers download_ziparchive_headers download_gtest_headers \
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

download_brotli_headers: $(INCLUDES_DIR)/brotli
$(INCLUDES_DIR)/brotli:
	@echo "Downloading brotli headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/brotli $(PLATFORM_TOOLS_REF) c/include/brotli/ $(INCLUDES_DIR)/brotli/ $(SUPPRESS_OUTPUT)

download_fmtlib_headers: $(INCLUDES_DIR)/fmt
$(INCLUDES_DIR)/fmt:
	@echo "Downloading fmtlib headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/fmtlib $(PLATFORM_TOOLS_REF) include/fmt/ $(INCLUDES_DIR)/fmt/ $(SUPPRESS_OUTPUT)

download_system_headers: $(INCLUDES_DIR)/system
$(INCLUDES_DIR)/system:
	@echo "Downloading system headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) libsystem/include/system/ $(INCLUDES_DIR)/system/ $(SUPPRESS_OUTPUT)

download_ziparchive_headers: $(INCLUDES_DIR)/ziparchive
$(INCLUDES_DIR)/ziparchive:
	@echo "Downloading ziparchive headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/libziparchive $(PLATFORM_TOOLS_REF) include/ziparchive/ $(INCLUDES_DIR)/ziparchive/ $(SUPPRESS_OUTPUT)

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
#  DOWNLOAD EXTERNAL   #
########################
all_download_external: download_zlib_external download_protobuf_external download_boringssl_external download_libusb_external	download_lz4_external \
	download_zstd_external download_mdnsresponder_external

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

download_mdnsresponder_external: $(EXTERNAL_DIR)/mdnsresponder
$(EXTERNAL_DIR)/mdnsresponder:
	@echo "Downloading mdnsresponder source ..."
	@git clone https://android.googlesource.com/platform/external/mdnsresponder --single-branch --branch $(PLATFORM_TOOLS_REF) $(EXTERNAL_DIR)/mdnsresponder/ $(SUPPRESS_OUTPUT)

########################
#        BUILD         #
########################
all_build: build_zlib_external build_protobuf_external build_libusb_external build_boringssl_external

build_zlib_external: download_zlib_external $(EXTERNAL_DIR)/zlib/libz.so
$(EXTERNAL_DIR)/zlib/libz.so:
	@echo "Building zlib ..."
	@cd $(EXTERNAL_DIR)/zlib; \
		./configure $(SUPPRESS_OUTPUT); \
		make $(SUPPRESS_OUTPUT)

build_protobuf_external: download_protobuf_external build_zlib_external $(EXTERNAL_DIR)/protobuf/protoc
$(EXTERNAL_DIR)/protobuf/protoc:
	@echo "Building protobuf ..."
	@cd $(EXTERNAL_DIR)/protobuf; \
		cmake ./cmake -DZLIB_LIBRARY=$(EXTERNAL_DIR)/zlib/libz.a -DZLIB_INCLUDE_DIR=$(EXTERNAL_DIR)/zlib/ $(SUPPRESS_OUTPUT); \
		cmake --build . -j$(NPROCS) $(SUPPRESS_OUTPUT); \
		echo "Testing protobuf build ..."; \
		cmake --build . --target check $(SUPPRESS_OUTPUT)

build_libusb_external: download_libusb_external $(EXTERNAL_DIR)/libusb/libusb/.libs/libusb-1.0.a
$(EXTERNAL_DIR)/libusb/libusb/.libs/libusb-1.0.a:
	@echo "Building libusb ..."
	@cd $(EXTERNAL_DIR)/libusb; \
		env ./autogen.sh --enable-static --disable-shared $(SUPPRESS_OUTPUT); \
		make $(SUPPRESS_OUTPUT);

build_boringssl_external: download_boringssl_external $(EXTERNAL_DIR)/boringssl/build/crypto/libcrypto.a $(EXTERNAL_DIR)/boringssl/build/ssl/libssl.a
$(EXTERNAL_DIR)/boringssl/build/crypto/libcrypto.a:
$(EXTERNAL_DIR)/boringssl/build/ssl/libssl.a:
	@echo "Building boringssl ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/googletest $(PLATFORM_TOOLS_REF) googletest/ $(EXTERNAL_DIR)/boringssl/third_party/googletest/ $(SUPPRESS_OUTPUT); \
		cd src/external/boringssl/; \
		sed -i 's/-Wformat=2 //' CMakeLists.txt; \
		mkdir build && cd build; \
		CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake .. $(SUPPRESS_OUTPUT); \
		make $(SUPPRESS_OUTPUT); \
		echo "Testing boringssl build ..."; \
		cd ..; \
		go run util/all_tests.go $(SUPPRESS_OUTPUT); \
		cd ssl/test/runner; \
		go test $(SUPPRESS_OUTPUT)

########################
#       COMPILE        #
########################
all_compile: compile_proto_files

PROTO_SOURCES := $(shell find $(SOURCE_DIR)/adb/proto/ $(SOURCE_DIR)/adb/fastdeploy/proto/ -name '*.proto')
PROTO_TARGETS := $(patsubst %.proto,%.pb.cc, $(PROTO_SOURCES)) $(patsubst %.proto,%.pb.h, $(PROTO_SOURCES))

# TODO: move to src/Makefile as the targets cannot be generated on first run because the files aren't present yet
compile_proto_files: download_adb_source build_protobuf_external $(PROTO_TARGETS)
$(PROTO_TARGETS)&:
	@echo "Compiling .proto files ..."
	@$(EXTERNAL_DIR)/protobuf/protoc -I=$(SOURCE_DIR)/adb/proto/ --cpp_out=$(SOURCE_DIR)/adb/proto/ $(SOURCE_DIR)/adb/proto/*.proto $(SUPPRESS_OUTPUT)
	@$(EXTERNAL_DIR)/protobuf/protoc -I=$(SOURCE_DIR)/adb/fastdeploy/proto/ --cpp_out=$(SOURCE_DIR)/adb/fastdeploy/proto/ $(SOURCE_DIR)/adb/fastdeploy/proto/*.proto $(SUPPRESS_OUTPUT)

########################
#         MISC         #
########################
clean:
	@rm -rf $(SOURCE_DIR)/adb $(STAMPS_DIR) $(DEPENDS_DIR) $(INCLUDES_DIR) $(EXTERNAL_DIR)
