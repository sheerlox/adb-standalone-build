HOSTARCH := $(shell uname -m | \
	sed -e s/i.86/i386/ \
	-e s/sun4u/sparc64/ \
	-e s/arm.*/arm/ \
	-e s/sa110/arm/ \
	-e s/ppc64/powerpc/ \
	-e s/ppc/powerpc/ \
	-e s/macppc/powerpc/)
OUT_DIR := ../out/$(HOSTARCH)

CXX = clang++ -std=c++20
CC  = clang

libdepends_a_TARGET := $(OUT_DIR)/libdepends.a
libadb_a_TARGET := $(OUT_DIR)/libadb.a
libmdnssd_a_TARGET := $(OUT_DIR)/libmsdbssd.a
adb_TARGET := $(OUT_DIR)/adb

libopenssl_INC := openssl/$(HOSTARCH)/include
libopenssl_LIB := openssl/$(HOSTARCH)/lib
libusb_INC := libusb-1.0/$(HOSTARCH)
libusb_LIB := libusb-1.0/$(HOSTARCH)/libusb-1.0

DEPENDS_INC := $(addprefix -I,$(wildcard depends/*/include))
ADB_INC := -Iadb -Iadb/proto $(addprefix -I,$(wildcard adb/*/include))
EXTERNAL_INC := -Iexternal/protobuf/src

ADB_COMMON_FLAGS := \
	-DADB_HOST=1 \
	-DANDROID_BASE_UNIQUE_FD_DISABLE_IMPLICIT_CONVERSION=1

all: $(libdepends_a_TARGET) $(libmdnssd_a_TARGET) $(libadb_a_TARGET) $(adb_TARGET)
adb: $(libadb_a_TARGET) $(adb_TARGET)

.PHONY: all

$(OUT_DIR):
ifneq ($(OUT_DIR), $(wildcard $(OUT_DIR)))
  $(shell mkdir -p $(OUT_DIR))
endif

########################
#     libdepends       #
########################
libdepends_a_INC := $(DEPENDS_INC)

libdepends_a_SOURCES_CXX := \
	depends/base/chrono_utils.cpp \
	depends/base/cmsg.cpp \
	depends/base/file.cpp \
	depends/base/logging.cpp \
	depends/base/mapped_file.cpp \
	depends/base/parsenetaddress.cpp \
	depends/base/properties.cpp \
	depends/base/stringprintf.cpp \
	depends/base/strings.cpp \
	depends/base/threads.cpp \
	depends/base/test_utils.cpp \
	depends/base/errors_unix.cpp \
	depends/log/config_read.cpp \
	depends/log/config_write.cpp \
	depends/log/log_event_list.cpp \
	depends/log/log_event_write.cpp \
	depends/log/logger_lock.cpp \
	depends/log/logger_name.cpp \
	depends/log/logger_read.cpp \
	depends/log/logger_write.cpp \
	depends/log/logprint.cpp \
	depends/log/stderr_write.cpp \
	depends/log/fake_log_device.cpp \
	depends/log/fake_writer.cpp \
	depends/cutils/config_utils.cpp \
	depends/cutils/canned_fs_config.cpp \
	depends/cutils/iosched_policy.cpp \
	depends/cutils/load_file.cpp \
	depends/cutils/native_handle.cpp \
	depends/cutils/record_stream.cpp \
	depends/cutils/sockets.cpp \
	depends/cutils/strdup16to8.cpp \
	depends/cutils/strdup8to16.cpp \
	depends/cutils/threads.cpp \
	depends/cutils/fs.cpp \
	depends/cutils/hashmap.cpp \
	depends/cutils/multiuser.cpp \
	depends/cutils/socket_inaddr_any_server_unix.cpp \
	depends/cutils/socket_local_client_unix.cpp \
	depends/cutils/socket_local_server_unix.cpp \
	depends/cutils/socket_network_client_unix.cpp \
	depends/cutils/sockets_unix.cpp \
	depends/cutils/str_parms.cpp \
	depends/cutils/ashmem-host.cpp \
	depends/cutils/fs_config.cpp \
	depends/cutils/trace-host.cpp \
	depends/diagnose_usb/diagnose_usb.cpp

libdepends_a_SOURCES_C := \
	depend/cutils/strlcpy.c

libdepends_a_CXXFLAGS := -DADB_HOST=1 -DFAKE_LOG_DEVICE=1

libdepends_a_OBJ_CXX := $(patsubst %.cpp,%.o, $(libdepends_a_SOURCES_CXX))
libdepends_a_OBJ_C := $(patsubst %.c,%.o, $(libdepends_a_SOURCES_C))

$(libdepends_a_OBJ_CXX): %.o:%.cpp
	$(CXX) -c $(libdepends_a_INC) $(libdepends_a_CXXFLAGS) $< -o $@
$(libdepends_a_OBJ_C):%.o:%.c
	$(CC) -c $(libdepends_a_INC) $(libdepends_a_CXXFLAGS) $< -o $@

$(libdepends_a_TARGET): $(OUT_DIR) $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_C)
	ar rc $(libdepends_a_TARGET) $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_C)

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
	-Wno-unused-const-variable \
	-Wno-unused-parameter \
	-Werror=implicit-function-declaration \
	-DTARGET_OS_LINUX \
	-DHAVE_LINUX \
	-DUSES_NETLINK \
	-DADB_HOST=1

libmdnssd_a_OBJ_C := $(patsubst %.c,%.o, $(libmdnssd_a_SOURCES_C))
$(libmdnssd_a_OBJ_C): %.o:%.c
	$(CC) -c $(libmdnssd_a_INC) $(libmdnssd_a_CFLAGS) $< -o $@

$(libmdnssd_a_TARGET): $(OUT_DIR) $(libmdnssd_a_OBJ_C)
	ar rc $(libmdnssd_a_TARGET) $(libmdnssd_a_OBJ_C)

########################
#       libadb         #
########################
libadb_a_INC := -Iincludes $(DEPENDS_INC) $(ADB_INC) $(EXTERNAL_INC)

bp_libadb_SOURCES := \
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
  adb/types.cpp

bp_libadb_linux_SOURCES := fdevent/fdevent_epoll.cpp

bp_libadb_posix_SOURCES := \
  adb/sysdeps_unix.cpp \
  adb/sysdeps/posix/network.cpp

bp_libadbd_core_SOURCES := \
  adb/daemon/adb_wifi.cpp \
	adb/daemon/auth.cpp \
	adb/daemon/jdwp_service.cpp \
	adb/daemon/logging.cpp \
	adb/daemon/transport_local.cpp

libadb_a_SOURCES := $(bp_libadb_SOURCES) $(bp_libadb_linux_SOURCES) $(bp_libadb_posix_SOURCES) $(bp_libadbd_core_SOURCES)

libadb_a_CXXFLAGS := $(ADB_COMMON_FLAGS)

libadb_a_OBJ_CXX := $(patsubst %.cpp,%.o, $(libadb_a_SOURCES))

$(libadb_a_OBJ_CXX): %.o:%.cpp
	$(CXX) -c $(libadb_a_INC) $(libadb_a_CXXFLAGS) $< -o $@

$(libadb_a_TARGET): $(OUT_DIR) $(libadb_a_OBJ_CXX)
	ar rc $(libadb_a_TARGET) $(libadb_a_OBJ_CXX)

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

adb_LDFLAG := $(libadb_a_TARGET) $(libmdnssd_a_TARGET) $(libdepends_a_TARGET) -L$(libusb_LIB) -l:libusb-1.0.a -ludev -L$(libopenssl_LIB) -l:libcrypto.a -ludev -lpthread -static-libgcc -static-libstdc++

adb_OBJ_CXX := $(patsubst %.cpp,%.o, $(adb_SOURCES))

$(adb_OBJ_CXX): %.o:%.cpp
	$(CXX) -c $(adb_INC) $(adb_CXXFLAGS) $< -o $@

$(adb_TARGET): $(OUT_DIR) $(adb_OBJ_CXX)
	$(CXX) -o $@ $^ $(adb_CXXFLAGS) $(libadb_a_TARGET) $(libmdnssd_a_TARGET) $(libdepends_a_TARGET) $(adb_LDFLAG)

clean:
	rm -rf $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_C) $(libadb_a_OBJ_CXX) $(libadb_a_OBJ_CXX) $(adb_OBJ_CXX) $(libmdnssd_a_OBJ_C) $(OUT_DIR)
