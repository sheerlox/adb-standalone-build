SHELL := /bin/bash

PLATFORM_TOOLS_VERSION := 31.0.0
PLATFORM_TOOLS_REF := platform-tools-$(PLATFORM_TOOLS_VERSION)

SOURCE_DIR := $(abspath src)
DEPENDS_DIR := $(SOURCE_DIR)/depends
INCLUDES_DIR := $(SOURCE_DIR)/includes
EXTERNAL_DIR := $(SOURCE_DIR)/external

NPROCS := $(shell grep -c ^processor /proc/cpuinfo)

SUPPRESS_OUTPUT := >/dev/null 2>&1

# create working directories if they don't exist
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
VERSION_EXISTS := $(shell git ls-remote --exit-code --tags https://android.googlesource.com/platform/manifest refs/tags/$(PLATFORM_TOOLS_REF) $(SUPPRESS_OUTPUT); echo $$?)
# $(info $(VERSION_EXISTS))
ifneq ($(VERSION_EXISTS),0)
  $(error Platform Tools version $(PLATFORM_TOOLS_VERSION) doesn't exist. Please refer to https://android.googlesource.com/platform/manifest/+refs for available tags)
else
  $(info Platform Tools version $(PLATFORM_TOOLS_VERSION) found!)
endif

all: all_download_source all_download_headers all_download_external all_build all_compile

########################
#   DOWNLOAD SOURCE    #
########################
all_download_source: download_adb_source download_libbase_source download_libcutils_source download_diagnose_usb_source download_boringssl_source

download_adb_source: $(SOURCE_DIR)/adb
$(SOURCE_DIR)/adb:
	@echo "Downloading adb source ..."
	@git clone https://android.googlesource.com/platform/packages/modules/adb --branch $(PLATFORM_TOOLS_REF) $(SOURCE_DIR)/adb $(SUPPRESS_OUTPUT)

download_libbase_source: $(DEPENDS_DIR)/base
$(DEPENDS_DIR)/base:
	@echo "Downloading libbase source ..."
	@git clone https://android.googlesource.com/platform/system/libbase --single-branch --branch $(PLATFORM_TOOLS_REF) $(DEPENDS_DIR)/base $(SUPPRESS_OUTPUT)
	@rm -rf $(DEPENDS_DIR)/base/.git

download_libcutils_source: $(DEPENDS_DIR)/cutils
$(DEPENDS_DIR)/cutils:
	@echo "Downloading libcutils source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) libcutils $(DEPENDS_DIR)/cutils $(SUPPRESS_OUTPUT)

download_diagnose_usb_source: $(DEPENDS_DIR)/diagnose_usb
$(DEPENDS_DIR)/diagnose_usb:
	@echo "Downloading diagnose_usb source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) diagnose_usb $(DEPENDS_DIR)/diagnose_usb $(SUPPRESS_OUTPUT)

download_boringssl_source: $(DEPENDS_DIR)/boringssl
$(DEPENDS_DIR)/boringssl:
	@echo "Downloading boringssl source ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/boringssl $(PLATFORM_TOOLS_REF) src $(DEPENDS_DIR)/boringssl $(SUPPRESS_OUTPUT)

########################
#   DOWNLOAD HEADERS   #
########################
all_download_headers: download_android_headers download_build_headers download_adbd_auth_headers generate_pt_version_header

download_android_headers: $(INCLUDES_DIR)/android
$(INCLUDES_DIR)/android:
	@echo "Downloading android headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/logging $(PLATFORM_TOOLS_REF) liblog/include/android/ $(INCLUDES_DIR)/android/ $(SUPPRESS_OUTPUT)

download_build_headers: $(INCLUDES_DIR)/build
$(INCLUDES_DIR)/build:
	@echo "Downloading build headers ..."
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/build/soong $(PLATFORM_TOOLS_REF) cc/libbuildversion/include/build/ $(INCLUDES_DIR)/build/ $(SUPPRESS_OUTPUT)

download_adbd_auth_headers: $(INCLUDES_DIR)/adbd_auth.h
$(INCLUDES_DIR)/adbd_auth.h:
	@echo "Downloading adbd_auth headers ..."
	@curl https://android.googlesource.com/platform/frameworks/native/+/refs/tags/$(PLATFORM_TOOLS_REF)/libs/adbd_auth/include/adbd_auth.h?format=text -s | base64 -d > $(INCLUDES_DIR)/adbd_auth.h

generate_pt_version_header: $(INCLUDES_DIR)/platform_tools_version.h
$(INCLUDES_DIR)/platform_tools_version.h:
	@echo "Generating platform tools version header ..."
	@echo '#define PLATFORM_TOOLS_VERSION "$(PLATFORM_TOOLS_VERSION)"' > $(INCLUDES_DIR)/platform_tools_version.h

########################
#  DOWNLOAD EXTERNAL   #
########################
all_download_external: download_zlib_external download_protobuf_external

download_zlib_external: $(EXTERNAL_DIR)/zlib
$(EXTERNAL_DIR)/zlib:
	@echo "Downloading zlib source ..."
	@git clone https://github.com/madler/zlib --single-branch --branch v$$(./utils/get_zlib_version.sh $(PLATFORM_TOOLS_VERSION)) $(EXTERNAL_DIR)/zlib $(SUPPRESS_OUTPUT)

download_protobuf_external: $(EXTERNAL_DIR)/protobuf
$(EXTERNAL_DIR)/protobuf:
	@echo "Downloading protobuf source ..."
	@git clone https://android.googlesource.com/platform/external/protobuf --recurse-submodules --single-branch --branch $(PLATFORM_TOOLS_REF) $(EXTERNAL_DIR)/protobuf $(SUPPRESS_OUTPUT)
	@rm -rf $(EXTERNAL_DIR)/protobuf/**/.git

########################
#        BUILD         #
########################
all_build: build_zlib_external build_protobuf_external

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

########################
#       COMPILE        #
########################
all_compile: compile_proto_files

compile_proto_files: download_adb_source build_protobuf_external $(SOURCE_DIR)/adb/proto/*.pb.h
$(SOURCE_DIR)/adb/proto/*.pb.h:
	@echo "Compiling .proto files ..."
	@$(EXTERNAL_DIR)/protobuf/protoc -I=$(SOURCE_DIR)/adb/proto/ --cpp_out=$(SOURCE_DIR)/adb/proto/ $(SOURCE_DIR)/adb/proto/*.proto

########################
#         MISC         #
########################
clean:
	@rm -rf $(SOURCE_DIR)/adb $(DEPENDS_DIR) $(INCLUDES_DIR) $(EXTERNAL_DIR)
