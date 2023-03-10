SHELL := /bin/bash

# stop execution if any of the root Makefile variables are not defined
ifeq ($(and $(CXX),$(CC),$(DEPENDS_DIR),$(INCLUDES_DIR),$(EXTERNAL_DIR),$(OUT_DIR),$(LIBS_DIR),$(INTER_DIR),$(BIN_DIR)),)
  $(error This Makefile should only be called from the root Makefile)
endif

libdepends_a_TARGET := $(INTER_DIR)/libdepends.a
libadb_a_TARGET := $(INTER_DIR)/libadb.a
libmdnssd_a_TARGET := $(INTER_DIR)/libmsdbssd.a
adb_TARGET := $(BIN_DIR)/adb

DEPENDS_INC := -Idepends/libziparchive/incfs_support/include -Idepends/mdnssd $(addprefix -I,$(wildcard depends/*/include))
ADB_INC := -Iadb -Iadb/crypto -Iadb/proto -Iadb/fastdeploy/proto -Iadb/pairing_connection/include \
	-Iadb/tls/include $(addprefix -I,$(wildcard adb/*/include))
EXTERNAL_INC := -Iexternal/protobuf/src -Iexternal/boringssl/include -Iexternal/libusb/include \
	-Iexternal/lz4/lib -Iexternal/zstd/lib -Iexternal/zlib -Iexternal/brotli/c/include

ADB_COMMON_FLAGS := \
	-DADB_HOST=1 \
	-DANDROID_BASE_UNIQUE_FD_DISABLE_IMPLICIT_CONVERSION=1

all: compile_proto_files $(libdepends_a_TARGET) $(libmdnssd_a_TARGET) $(libadb_a_TARGET) $(adb_TARGET)

.PHONY: all

########################
#     proto files      #
########################
PROTO_SOURCES := $(shell find adb/proto/ adb/fastdeploy/proto/ -name '*.proto')
PROTO_TARGETS := $(patsubst %.proto,%.pb.cc, $(PROTO_SOURCES)) $(patsubst %.proto,%.pb.h, $(PROTO_SOURCES))

compile_proto_files: $(PROTO_TARGETS)
$(PROTO_TARGETS)&:
	$(LIBS_DIR)/protoc -I=adb/proto/ --cpp_out=adb/proto/ adb/proto/*.proto $(SUPPRESS_OUTPUT)
	$(LIBS_DIR)/protoc -I=adb/fastdeploy/proto/ --cpp_out=adb/fastdeploy/proto/ adb/fastdeploy/proto/*.proto $(SUPPRESS_OUTPUT)

########################
#     libdepends       #
########################
libdepends_a_INC := -Iincludes $(ADB_INC) $(DEPENDS_INC) $(EXTERNAL_INC)

libdepends_a_SOURCES_CXX := \
	depends/base/chrono_utils.cpp \
	depends/base/cmsg.cpp \
	depends/base/file.cpp \
	depends/base/logging.cpp \
	depends/base/mapped_file.cpp \
	depends/base/parsebool.cpp \
	depends/base/parsenetaddress.cpp \
	depends/base/properties.cpp \
	depends/base/stringprintf.cpp \
	depends/base/strings.cpp \
	depends/base/threads.cpp \
	depends/crypto_utils/android_pubkey.cpp \
	depends/cutils/sockets.cpp \
	depends/androidfw/ZipFileRO.cpp \
	depends/androidfw/ResourceTypes.cpp \
	depends/androidfw/LocaleData.cpp \
	depends/androidfw/TypeWrappers.cpp \
	depends/utils/String8.cpp \
	depends/utils/String16.cpp \
	depends/utils/Unicode.cpp \
	depends/utils/SharedBuffer.cpp \
	depends/utils/FileMap.cpp \
	depends/utils/VectorImpl.cpp \
	depends/log/log_event_list.cpp \
	depends/log/log_event_write.cpp \
	depends/log/logger_write.cpp \
	depends/log/properties.cpp \
	depends/incfs_util/map_ptr.cpp \
	depends/buildversion/libbuildversion.cpp \
	depends/libziparchive/zip_error.cpp \
	depends/diagnose_usb/diagnose_usb.cpp \
	depends/cutils/socket_local_server_unix.cpp \
	depends/cutils/socket_local_client_unix.cpp \
	depends/cutils/socket_network_client_unix.cpp \
	depends/cutils/socket_inaddr_any_server_unix.cpp \

libdepends_a_SOURCES_CC := \
	depends/libziparchive/zip_archive.cc \
	depends/libziparchive/zip_cd_entry_map.cc \

libdepends_a_CXXFLAGS := -DADB_HOST=1 -DFAKE_LOG_DEVICE=1

libdepends_a_OBJ_CXX := $(patsubst %.cpp,%.o, $(libdepends_a_SOURCES_CXX))
libdepends_a_OBJ_CC := $(patsubst %.cc,%.o, $(libdepends_a_SOURCES_CC))

$(libdepends_a_OBJ_CXX): %.o:%.cpp
	$(CXX) $(libdepends_a_INC) $(libdepends_a_CXXFLAGS) -c $< -o $@
$(libdepends_a_OBJ_CC): %.o:%.cc
	$(CXX) $(libdepends_a_INC) $(libdepends_a_CXXFLAGS) -c $< -o $@

$(libdepends_a_TARGET): $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_CC)
	ar rc $(libdepends_a_TARGET) $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_CC)

########################
#      libmdnssd       #
########################
libmdnssd_a_INC := -Idepends/mdnssd

libmdnssd_a_SOURCES_C := \
	depends/mdnssd/dnssd_clientlib.c \
	depends/mdnssd/dnssd_clientstub.c \
	depends/mdnssd/dnssd_ipc.c

libmdnssd_a_CFLAGS := \
	-O2 \
	-g \
	-fno-strict-aliasing \
	-fwrapv \
	-D_GNU_SOURCE \
	-DHAVE_IPV6 \
	-DNOT_HAVE_SA_LEN \
	-DPLATFORM_NO_RLIMIT \
	-DMDNS_DEBUGMSGS=0 \
	-DMDNS_UDS_SERVERPATH=\"/dev/socket/mdnsd\" \
	-DMDNS_USERNAME=\"mdnsr\" \
	-W \
	-Wall \
	-Wextra \
	-Wno-address-of-packed-member \
	-Wno-array-bounds \
	-Wno-pointer-sign \
	-Wno-unused \
	-Wno-unused-but-set-variable \
	-Wno-unused-parameter \
	-Werror=implicit-function-declaration \
	-DTARGET_OS_LINUX \
	-DHAVE_LINUX \
	-DUSES_NETLINK

libmdnssd_a_OBJ_C := $(patsubst %.c,%.o, $(libmdnssd_a_SOURCES_C))
$(libmdnssd_a_OBJ_C): %.o:%.c
	$(CC) $(libmdnssd_a_INC) $(libmdnssd_a_CFLAGS) -c $< -o $@

$(libmdnssd_a_TARGET): $(libmdnssd_a_OBJ_C)
	ar rc $(libmdnssd_a_TARGET) $(libmdnssd_a_OBJ_C)

########################
#       libadb         #
########################
libadb_a_INC := -Iincludes $(DEPENDS_INC) $(ADB_INC) $(EXTERNAL_INC)

libadb_a_SOURCES_CXX := \
	adb/adb.cpp \
	adb/adb_io.cpp \
	adb/adb_listeners.cpp \
	adb/adb_trace.cpp \
	adb/adb_unique_fd.cpp \
	adb/adb_utils.cpp \
	adb/fdevent/fdevent.cpp \
	adb/services.cpp \
	adb/sockets.cpp \
	adb/socket_spec.cpp \
	adb/sysdeps/env.cpp \
	adb/sysdeps/errno.cpp \
	adb/transport.cpp \
	adb/transport_fd.cpp \
	adb/types.cpp \
	adb/client/auth.cpp \
	adb/client/adb_wifi.cpp \
	adb/client/usb_libusb.cpp \
	adb/client/usb_dispatch.cpp \
	adb/client/transport_local.cpp \
	adb/client/transport_mdns.cpp \
	adb/client/mdns_utils.cpp \
	adb/client/transport_usb.cpp \
	adb/client/pairing/pairing_client.cpp \
	adb/crypto/key.cpp \
	adb/crypto/rsa_2048_key.cpp \
	adb/crypto/x509_generator.cpp \
	adb/pairing_auth/pairing_auth.cpp \
	adb/pairing_auth/aes_128_gcm.cpp \
	adb/pairing_connection/pairing_connection.cpp \
	adb/tls/adb_ca_list.cpp \
	adb/tls/tls_connection.cpp \
	adb/fastdeploy/deploypatchgenerator/apk_archive.cpp \
	adb/fastdeploy/deploypatchgenerator/deploy_patch_generator.cpp \
	adb/fastdeploy/deploypatchgenerator/patch_utils.cpp

libadb_a_linux_SOURCES_CXX := \
	adb/client/usb_linux.cpp \
	adb/fdevent/fdevent_epoll.cpp

libadb_a_posix_SOURCES_CXX := \
  adb/sysdeps_unix.cpp \
  adb/sysdeps/posix/network.cpp

libadb_a_SOURCES_CXX := $(libadb_a_SOURCES_CXX) $(libadb_a_linux_SOURCES_CXX) $(libadb_a_posix_SOURCES_CXX)

libadb_a_SOURCES_CC := \
	adb/proto/adb_known_hosts.pb.cc \
	adb/proto/app_processes.pb.cc \
	adb/proto/key_type.pb.cc \
	adb/proto/pairing.pb.cc \
	adb/fastdeploy/proto/ApkEntry.pb.cc

libadb_a_CXXFLAGS := $(ADB_COMMON_FLAGS)

libadb_a_OBJ_CXX := $(patsubst %.cpp,%.o, $(libadb_a_SOURCES_CXX))
libadb_a_OBJ_CC := $(patsubst %.cc,%.o, $(libadb_a_SOURCES_CC))

$(libadb_a_OBJ_CXX): %.o:%.cpp
	$(CXX) $(libadb_a_INC) $(libadb_a_CXXFLAGS) -c $< -o $@
$(libadb_a_OBJ_CC): %.o:%.cc
	$(CXX) $(libadb_a_INC) $(libadb_a_CXXFLAGS) -c $< -o $@

$(libadb_a_TARGET): $(libadb_a_OBJ_CXX) $(libadb_a_OBJ_CC)
	ar rc $(libadb_a_TARGET) $(libadb_a_OBJ_CXX) $(libadb_a_OBJ_CC)

########################
#         adb          #
########################
adb_INC := -Iincludes $(DEPENDS_INC) $(ADB_INC) $(EXTERNAL_INC)

adb_SOURCES := \
	adb/client/adb_client.cpp \
	adb/client/bugreport.cpp \
	adb/client/commandline.cpp \
	adb/client/file_sync_client.cpp \
	adb/client/main.cpp \
	adb/client/console.cpp \
	adb/client/adb_install.cpp \
	adb/client/line_printer.cpp \
	adb/client/fastdeploy.cpp \
	adb/client/fastdeploycallbacks.cpp \
	adb/client/incremental.cpp \
	adb/client/incremental_server.cpp \
	adb/client/incremental_utils.cpp \
	adb/shell_service_protocol.cpp

adb_CXXFLAGS :=	-std=gnu++20 -D_GNU_SOURCE $(ADB_COMMON_FLAGS) -D_Nonnull= -D_Nullable= -fpermissive

adb_LDFLAG := -ludev -lpthread -static-libgcc -static-libstdc++ -L$(LIBS_DIR) -l:libprotobuf.a -l:libssl.a -l:libcrypto.a -l:libz.a \
	-l:liblz4.a -l:libzstd.a -l:libbrotlienc-static.a -l:libbrotlidec-static.a -l:libbrotlicommon-static.a -l:libusb-1.0.a

adb_OBJ_CXX := $(patsubst %.cpp,%.o, $(adb_SOURCES))

$(adb_OBJ_CXX): %.o:%.cpp
	$(CXX) $(adb_INC) $(adb_CXXFLAGS) -c $< -o $@

$(adb_TARGET): $(adb_OBJ_CXX)
	$(CXX) -o $@ $^ $(adb_CXXFLAGS) $(libadb_a_TARGET) $(libmdnssd_a_TARGET) $(libdepends_a_TARGET) $(adb_LDFLAG)

clean:
	rm -rf $(BIN_DIR) $(INTER_DIR) $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_CC) $(libadb_a_OBJ_CXX) $(libadb_a_OBJ_CC) $(adb_OBJ_CXX) $(libmdnssd_a_OBJ_C) $(PROTO_TARGETS)
