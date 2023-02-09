HOSTARCH := $(shell uname -m | \
	sed -e s/i.86/i386/ \
	-e s/sun4u/sparc64/ \
	-e s/arm.*/arm/ \
	-e s/sa110/arm/ \
	-e s/ppc64/powerpc/ \
	-e s/ppc/powerpc/ \
	-e s/macppc/powerpc/)

CXX = clang++ -std=c++20
CC  = clang

shell:
ifneq (openssl, $(wildcard openssl))
	$(shell ln -s /work/openssl openssl)
endif
ifneq (out/$(HOSTARCH), $(wildcard out/$(HOSTARCH)))
	$(shell mkdir -p out/$(HOSTARCH))
endif	


libdepend_a_TARGET := out/$(HOSTARCH)/libdepend.a
libadb_a_TARGET := out/$(HOSTARCH)/libadb.a
libmdnssd_a_TARGET := out/$(HOSTARCH)/libmsdbssd.a
adb_TARGET := out/$(HOSTARCH)/adb

.PHONY: all

all:$(libdepend_a_TARGET) $(libmdnssd_a_TARGET) $(libadb_a_TARGET) $(adb_TARGET)

libopenssl_INC := openssl/$(HOSTARCH)/include
libopenssl_LIB := openssl/$(HOSTARCH)/lib
libusb_INC := libusb-1.0/$(HOSTARCH)
libusb_LIB := libusb-1.0/$(HOSTARCH)/libusb-1.0

#编译lia
libdepend_a_INC := -I$(libopenssl_INC) -Idepend -Idepend/diagnose_usb

libdepend_a_SOURCES_CXX := \
        depend/android-base/chrono_utils.cpp \
        depend/android-base/cmsg.cpp \
        depend/android-base/file.cpp \
        depend/android-base/logging.cpp \
        depend/android-base/mapped_file.cpp \
        depend/android-base/parsenetaddress.cpp \
        depend/android-base/properties.cpp \
        depend/android-base/quick_exit.cpp \
        depend/android-base/stringprintf.cpp \
        depend/android-base/strings.cpp \
        depend/android-base/threads.cpp \
        depend/android-base/test_utils.cpp \
        depend/android-base/errors_unix.cpp \
	depend/log/config_read.cpp \
	depend/log/config_write.cpp \
	depend/log/log_event_list.cpp \
	depend/log/log_event_write.cpp \
	depend/log/logger_lock.cpp \
	depend/log/logger_name.cpp \
	depend/log/logger_read.cpp \
	depend/log/logger_write.cpp \
	depend/log/logprint.cpp \
	depend/log/stderr_write.cpp \
        depend/log/fake_log_device.cpp \
        depend/log/fake_writer.cpp \
	depend/cutils/config_utils.cpp \
	depend/cutils/canned_fs_config.cpp \
	depend/cutils/iosched_policy.cpp \
	depend/cutils/load_file.cpp \
	depend/cutils/native_handle.cpp \
	depend/cutils/record_stream.cpp \
	depend/cutils/sockets.cpp \
	depend/cutils/strdup16to8.cpp \
	depend/cutils/strdup8to16.cpp \
	depend/cutils/threads.cpp \
	depend/cutils/fs.cpp \
	depend/cutils/hashmap.cpp \
	depend/cutils/multiuser.cpp \
	depend/cutils/socket_inaddr_any_server_unix.cpp \
	depend/cutils/socket_local_client_unix.cpp \
	depend/cutils/socket_local_server_unix.cpp \
	depend/cutils/socket_network_client_unix.cpp \
	depend/cutils/sockets_unix.cpp \
	depend/cutils/str_parms.cpp \
	depend/cutils/ashmem-host.cpp \
	depend/cutils/fs_config.cpp \
	depend/cutils/trace-host.cpp \
	depend/diagnose_usb/diagnose_usb.cpp


libdepend_a_SOURCES_C := \
	depend/cutils/strlcpy.c \
	depend/android-base/android_pubkey.c

libdepend_a_CXXFLAGS := -DFAKE_LOG_DEVICE=1  -DADB_HOST=1


libdepend_a_OBJ_CXX := $(patsubst %.cpp,%.o, $(libdepend_a_SOURCES_CXX))
libdepend_a_OBJ_C := $(patsubst %.c,%.o, $(libdepend_a_SOURCES_C))


$(libdepend_a_OBJ_CXX):%.o:%.cpp
	$(CXX) -c  $(libdepend_a_INC) $(libdepend_a_CXXFLAGS) $< -o $@
$(libdepend_a_OBJ_C):%.o:%.c
	$(CC) -c  $(libdepend_a_INC) $(libdepend_a_CXXFLAGS) $< -o $@


$(libdepend_a_TARGET):$(libdepend_a_OBJ_CXX) $(libdepend_a_OBJ_C)
	ar rc $(libdepend_a_TARGET) $(libdepend_a_OBJ_CXX) $(libdepend_a_OBJ_C)


#编译libmdnssd.a
libmdnssd_a_INC := -Idepend/mdnssd


libmdnssd_a_SOURCES_C := \
	depend/mdnssd/dnssd_clientlib.c \
	depend/mdnssd/dnssd_clientstub.c \
	depend/mdnssd/dnssd_ipc.c

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
$(libmdnssd_a_OBJ_C):%.o:%.c
	$(CC) -c  $(libmdnssd_a_INC) $(libmdnssd_a_CFLAGS) $< -o $@

$(libmdnssd_a_TARGET):$(libmdnssd_a_OBJ_C)
	ar rc $(libmdnssd_a_TARGET) $(libmdnssd_a_OBJ_C)

#编译libadb.a
libadb_a_INC :=  -I$(libusb_INC) -I$(libopenssl_INC) -Idepend -Iadb

libadb_a_SOURCES := \
	adb/adb.cpp \
	adb/adb_io.cpp \
	adb/adb_listeners.cpp \
	adb/adb_trace.cpp \
	adb/adb_unique_fd.cpp \
	adb/adb_utils.cpp \
	adb/fdevent.cpp \
	adb/services.cpp \
	adb/sockets.cpp \
	adb/socket_spec.cpp \
	adb/sysdeps/errno.cpp \
	adb/transport.cpp \
	adb/transport_fd.cpp \
	adb/transport_local.cpp \
	adb/transport_usb.cpp \
	adb/sysdeps_unix.cpp \
	adb/sysdeps/posix/network.cpp \
	adb/client/auth.cpp \
	adb/client/usb_libusb.cpp \
	adb/client/usb_dispatch.cpp \
	adb/client/transport_mdns.cpp \
	adb/client/usb_linux.cpp

libadb_a_CXXFLAGS := -DADB_HOST=1 $(ADB_COMMON_CFLAGS) \

libadb_a_OBJ_CXX := $(patsubst %.cpp,%.o, $(libadb_a_SOURCES))

$(libadb_a_OBJ_CXX):%.o:%.cpp
	$(CXX) -c  $(libadb_a_INC) $(libadb_a_CXXFLAGS) $< -o $@

$(libadb_a_TARGET):$(libadb_a_OBJ_CXX)
	ar rc $(libadb_a_TARGET) $(libadb_a_OBJ_CXX)

#编译adb
adb_INC := -I$(libopenssl_INC) -I$(libusb_INC) -Idepend -Iadb

adb_SOURCES := \
	adb/client/adb_client.cpp \
	adb/client/bugreport.cpp \
	adb/client/commandline.cpp \
	adb/client/file_sync_client.cpp \
	adb/client/main.cpp \
	adb/client/console.cpp \
	adb/client/adb_install.cpp \
	adb/client/line_printer.cpp \
	adb/shell_service_protocol.cpp

adb_CXXFLAGS :=	-std=gnu++2a -D_GNU_SOURCE -DADB_HOST=1 $(ADB_COMMON_CFLAGS) -D_Nonnull= -D_Nullable= -fpermissive

adb_LDFLAG :=  $(libadb_a_TARGET) $(libmdnssd_a_TARGET) $(libdepend_a_TARGET) -L$(libusb_LIB) -l:libusb-1.0.a -ludev -L$(libopenssl_LIB) -l:libcrypto.a  -ludev -lpthread -static-libgcc -static-libstdc++

adb_OBJ_CXX := $(patsubst %.cpp,%.o, $(adb_SOURCES))

$(adb_OBJ_CXX):%.o:%.cpp
	$(CXX) -c  $(adb_INC) $(adb_CXXFLAGS) $< -o $@

$(adb_TARGET):$(adb_OBJ_CXX)
	$(CXX) -o  $@ $^ $(adb_CXXFLAGS) $(libadb_a_TARGET) $(libmdnssd_a_TARGET) $(libdepend_a_TARGET) $(adb_LDFLAG)

clean:
	rm -rf $(libdepend_a_OBJ_CXX) $(libdepend_a_OBJ_C) $(libadb_a_OBJ_CXX) $(libadb_a_OBJ_CXX) $(adb_OBJ_CXX)  $(libmdnssd_a_OBJ_C) out/$(HOSTARCH)
