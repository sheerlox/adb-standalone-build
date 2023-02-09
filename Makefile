SHELL := /bin/bash
PLATFORM_TOOLS_VERSION := 31.0.0
PLATFORM_TOOLS_REF := platform-tools-$(PLATFORM_TOOLS_VERSION)
SOURCE_DIR := src
DEPENDS_DIR := $(SOURCE_DIR)/depends
INCLUDES_DIR := $(SOURCE_DIR)/includes

SUPPRESS_OUTPUT := >/dev/null 2>&1

# create working directories if they don't exist
ifneq ($(DEPENDS_DIR), $(wildcard $(DEPENDS_DIR)))
  $(shell mkdir -p $(DEPENDS_DIR))
endif
ifneq ($(INCLUDES_DIR), $(wildcard $(INCLUDES_DIR)))
  $(shell mkdir -p $(INCLUDES_DIR))
endif

# check if the specified Platform Tools version exists on platform/manifest
$(info Checking if Platform Tools version $(PLATFORM_TOOLS_VERSION) exists...)
VERSION_EXISTS := $(shell git ls-remote --exit-code --tags https://android.googlesource.com/platform/manifest refs/tags/$(PLATFORM_TOOLS_REF) $(SUPPRESS_OUTPUT); echo $$?)
# $(info $(VERSION_EXISTS))
ifneq ($(VERSION_EXISTS),0)
  $(error Platform Tools version $(PLATFORM_TOOLS_VERSION) doesn't exist. Please refer to https://android.googlesource.com/platform/manifest/+refs for available tags)
else
  $(info Platform Tools version $(PLATFORM_TOOLS_VERSION) found!)
endif

all: all_download_source all_download_headers generate_pt_version_header

########################
# DOWNLOAD SOURCE CODE #
########################
all_download_source: download_adb_source download_libbase_source download_libcutils_source download_boringssl_source

download_adb_source: $(SOURCE_DIR)/adb
$(SOURCE_DIR)/adb:
	$(info Downloading adb source code ...)
	@git clone https://android.googlesource.com/platform/packages/modules/adb --branch $(PLATFORM_TOOLS_REF) $(SOURCE_DIR)/adb $(SUPPRESS_OUTPUT)

download_libbase_source: $(DEPENDS_DIR)/base
$(DEPENDS_DIR)/base:
	$(info Downloading libbase source code ...)
	@git clone https://android.googlesource.com/platform/system/libbase --single-branch --branch $(PLATFORM_TOOLS_REF) $(DEPENDS_DIR)/base $(SUPPRESS_OUTPUT)
	@rm -rf $(DEPENDS_DIR)/base/.git

download_libcutils_source: $(DEPENDS_DIR)/cutils
$(DEPENDS_DIR)/cutils:
	$(info Downloading libcutils source code ...)
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) libcutils $(DEPENDS_DIR)/cutils $(SUPPRESS_OUTPUT)

download_boringssl_source: $(DEPENDS_DIR)/boringssl
$(DEPENDS_DIR)/boringssl:
	$(info Downloading boringssl source code ...)
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/external/boringssl $(PLATFORM_TOOLS_REF) src $(DEPENDS_DIR)/boringssl $(SUPPRESS_OUTPUT)

########################
#   DOWNLOAD HEADERS   #
########################
all_download_headers: download_android_headers download_build_headers

download_android_headers: $(INCLUDES_DIR)/android
$(INCLUDES_DIR)/android:
	$(info Downloading android headers ...)
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/logging $(PLATFORM_TOOLS_REF) liblog/include/android/ $(INCLUDES_DIR)/android/ $(SUPPRESS_OUTPUT)

download_build_headers: $(INCLUDES_DIR)/build
$(INCLUDES_DIR)/build:
	$(info Downloading build headers ...)
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/build/soong $(PLATFORM_TOOLS_REF) cc/libbuildversion/include/build/ $(INCLUDES_DIR)/build/ $(SUPPRESS_OUTPUT)

generate_pt_version_header: $(INCLUDES_DIR)/platform_tools_version.h
$(INCLUDES_DIR)/platform_tools_version.h:
	$(info Generating platform tools version header ...)
	@echo '#define PLATFORM_TOOLS_VERSION "$(PLATFORM_TOOLS_VERSION)"' > $(INCLUDES_DIR)/platform_tools_version.h


clean:
	@rm -rf $(SOURCE_DIR)/adb $(DEPENDS_DIR) $(INCLUDES_DIR)
