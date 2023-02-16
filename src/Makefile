HOSTARCH := $(shell uname -m | \
	sed -e s/i.86/i386/ \
	-e s/sun4u/sparc64/ \
	-e s/arm.*/arm/ \
	-e s/sa110/arm/ \
	-e s/ppc64/powerpc/ \
	-e s/ppc/powerpc/ \
	-e s/macppc/powerpc/)
OUT_DIR := ../out/$(HOSTARCH)

ifneq ($(OUT_DIR), $(wildcard $(OUT_DIR)))
  $(shell mkdir -p $(OUT_DIR))
endif

CXX = clang++ -std=c++20
CC  = clang

libdepends_a_TARGET := $(OUT_DIR)/libdepends.a
libadb_a_TARGET := $(OUT_DIR)/libadb.a
adb_TARGET := $(OUT_DIR)/adb

DEPENDS_INC := $(addprefix -I,$(wildcard depends/*/include))
ADB_INC := -Iadb -Iadb/proto $(addprefix -I,$(wildcard adb/*/include))
EXTERNAL_INC := -Iexternal/protobuf/src -Iexternal/boringssl/include -Iexternal/libusb/include -Iexternal/lz4/lib -Iexternal/zstd/lib -Iexternal/mdnsresponder/mDNSShared

ADB_COMMON_FLAGS := \
	-DADB_HOST=1 \
	-DANDROID_BASE_UNIQUE_FD_DISABLE_IMPLICIT_CONVERSION=1

all: $(libdepends_a_TARGET) $(libadb_a_TARGET) $(adb_TARGET)
adb: $(libadb_a_TARGET) $(adb_TARGET)

.PHONY: all

########################
#     libdepends       #
########################
libdepends_a_INC := $(DEPENDS_INC) $(EXTERNAL_INC)

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
	depends/cutils/sockets.cpp

libdepends_a_SOURCES_CC := \
	adb/proto/adb_known_hosts.pb.cc \
	adb/proto/app_processes.pb.cc \
	adb/proto/key_type.pb.cc \
	adb/proto/pairing.pb.cc

libdepends_a_CXXFLAGS := -DADB_HOST=1 -DFAKE_LOG_DEVICE=1

libdepends_a_OBJ_CXX := $(patsubst %.cpp,%.o, $(libdepends_a_SOURCES_CXX))
libdepends_a_OBJ_CC := $(patsubst %.cc,%.o, $(libdepends_a_SOURCES_CC))

$(libdepends_a_OBJ_CXX): %.o:%.cpp
	$(CXX) -c $(libdepends_a_INC) $(libdepends_a_CXXFLAGS) $< -o $@
$(libdepends_a_OBJ_CC): %.o:%.cc
	$(CXX) -c $(libdepends_a_INC) $(libdepends_a_CXXFLAGS) $< -o $@

$(libdepends_a_TARGET): $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_CC)
	ar rc $(libdepends_a_TARGET) $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_CC)

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
  adb/types.cpp \
	adb/client/auth.cpp \
	adb/client/adb_wifi.cpp \
	adb/client/usb_libusb.cpp \
	adb/client/usb_dispatch.cpp \
	adb/client/transport_local.cpp \
	adb/client/transport_mdns.cpp \
	adb/client/mdns_utils.cpp \
	adb/client/transport_usb.cpp \
	adb/client/pairing/pairing_client.cpp

bp_libadb_linux_SOURCES := adb/fdevent/fdevent_epoll.cpp

bp_libadb_posix_SOURCES := \
  adb/sysdeps_unix.cpp \
  adb/sysdeps/posix/network.cpp

libadb_a_SOURCES := $(bp_libadb_SOURCES) $(bp_libadb_linux_SOURCES) $(bp_libadb_posix_SOURCES)

libadb_a_CXXFLAGS := $(ADB_COMMON_FLAGS)

libadb_a_OBJ_CXX := $(patsubst %.cpp,%.o, $(libadb_a_SOURCES))

$(libadb_a_OBJ_CXX): %.o:%.cpp
	$(CXX) -c $(libadb_a_INC) $(libadb_a_CXXFLAGS) $< -o $@

$(libadb_a_TARGET): $(libadb_a_OBJ_CXX)
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

adb_LDFLAG := -Lexternal/libusb/libusb/.libs -l:libusb-1.0.a -ludev -lpthread -static-libgcc -static-libstdc++

adb_OBJ_CXX := $(patsubst %.cpp,%.o, $(adb_SOURCES))

$(adb_OBJ_CXX): %.o:%.cpp
	$(CXX) -c $(adb_INC) $(adb_CXXFLAGS) $< -o $@

$(adb_TARGET): $(adb_OBJ_CXX)
	$(CXX) -o $@ $^ $(adb_CXXFLAGS) $(libadb_a_TARGET) $(libdepends_a_TARGET) $(adb_LDFLAG)

clean:
	rm -rf $(libdepends_a_OBJ_CXX) $(libdepends_a_OBJ_C) $(libadb_a_OBJ_CXX) $(libadb_a_OBJ_CXX) $(adb_OBJ_CXX) $(OUT_DIR)
