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

all: download_adb download_libbase download_libcutils download_build_headers generate_platform_tools_version_header

download_adb: $(SOURCE_DIR)/adb
$(SOURCE_DIR)/adb:
	$(info Downloading adb source code ...)
	@git clone https://android.googlesource.com/platform/packages/modules/adb --branch $(PLATFORM_TOOLS_REF) $(SOURCE_DIR)/adb $(SUPPRESS_OUTPUT)

download_libbase: $(DEPENDS_DIR)/libbase
$(DEPENDS_DIR)/libbase:
	$(info Downloading libbase source code ...)
	@git clone https://android.googlesource.com/platform/system/libbase --single-branch --branch $(PLATFORM_TOOLS_REF) $(DEPENDS_DIR)/libbase $(SUPPRESS_OUTPUT)
	@rm -rf $(DEPENDS_DIR)/libbase/.git

download_libcutils: $(DEPENDS_DIR)/libcutils
$(DEPENDS_DIR)/libcutils:
	$(info Downloading libcutils source code ...)
	@bash utils/git_sparse.sh https://android.googlesource.com/platform/system/core $(PLATFORM_TOOLS_REF) libcutils $(DEPENDS_DIR) $(SUPPRESS_OUTPUT)

download_build_headers: $(INCLUDES_DIR)/android
$(INCLUDES_DIR)/android:
	$(info Downloading build headers ...)
	@mkdir -p $(INCLUDES_DIR)/android/
	@curl https://android.googlesource.com/platform/system/logging/+/refs/tags/$(PLATFORM_TOOLS_REF)/liblog/include/android/log.h?format=text $(SUPPRESS_OUTPUT) | base64 -d > $(INCLUDES_DIR)/android/log.h

generate_platform_tools_version_header: $(INCLUDES_DIR)/platform_tools_version.h
$(INCLUDES_DIR)/platform_tools_version.h:
	@echo '#define PLATFORM_TOOLS_VERSION "$(PLATFORM_TOOLS_VERSION)"' > $(INCLUDES_DIR)/platform_tools_version.h


clean:
	@rm -rf $(SOURCE_DIR)/adb $(DEPENDS_DIR) $(INCLUDES_DIR)
